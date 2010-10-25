
module Timber
  class Table
    attr_reader :column_names, :file_stream, :column_types
    
    def self.new_from_file(server, filename, working_dir, column_names)
      executor = RemoteExecutor.new(server)
      fs = FileStream.new(executor, working_dir)
      fs.force_current(filename)
      new(fs, column_names)
    end
    
    def initialize(file_stream, column_names)
      @file_stream  = file_stream
      @column_names = column_names
    end
    
    def set_types(column_types)
      @column_types = column_types
    end
    
    def type_of_column(name)
      ix = column_ix(name)
      @column_types[ix]
    end
    
    def current_file
      @file_stream.current
    end
    
    def to_a
      rows = []
      each_row_from(file_stream.current) do |bits|
        rows << bits
      end
      rows
    end
    
    def rename_column(old_name, new_name)
      @column_names = @column_names.map {|name| name == old_name ? new_name : name }
    end
    
    def column_values(name)
      values = []
      ix = column_ix(name)
      each_row_from(file_stream.current) do |bits|
        values << bits[ix]
      end
      values
    end
    
    def map_column(name)
      ix = column_ix(name)
      source      = file_stream.current
      destination = file_stream.next_file
      fout = File.open(destination, "w")
      each_row_from(source) do |bits|
        current_value = bits[ix]
        bits[ix] = yield(current_value)
        fout.puts bits.join(",")
      end
      fout.close
    end
    
    def length
      file_stream.length
    end
    
    def uniq
      source      = current_file
      destination = file_stream.next_file
      uniq_cmd = "sort #{source} | uniq"
      executor.ssh_into(uniq_cmd, destination)
    end
    
    def top(n, column_name)
      ix          = column_ix(column_name)
      rows        = []
      current_min = nil
      
      each_row_from(file_stream.current) do |row|
        value = row[ix]
        if rows.length < n
          rows << [value, row]
          rows = rows.sort_by {|value, row| value }
          current_min = rows.first.first
        elsif value > current_min
          rows << [value, row]
          rows = rows.sort_by {|value, row| value }
          rows[0..0] = nil
          current_min = rows.first.first
        end
      end
      rows.map {|value, row| row}.reverse
    end
    
    def bottom(n, column_name)
      ix          = column_ix(column_name)
      rows        = []
      current_max = nil
      
      each_row_from(file_stream.current) do |row|
        value = row[ix]
        if rows.length < n
          rows << [value, row]
          rows = rows.sort_by {|value, row| value }
          current_max = rows.last.first
        elsif value < current_max
          rows << [value, row]
          rows = rows.sort_by {|value, row| value }
          rows[-1..-1] = nil
          current_max = rows.last.first
        end
      end
      rows.map {|value, row| row}
    end
    
    def sub_table(options=nil)
      source = file_stream.current
      new_file_stream = FileStream.new(executor, file_stream.working_dir)
      next_file = new_file_stream.next_file
      if options and columns = options[:columns]
        ixes = columns.map {|col| column_ix(col) }
        File.open(next_file, "w") do |fout|
          each_row_from(source) do |row|
            new_bits = []
            ixes.each {|ix| new_bits << row[ix]}
            fout.puts new_bits.join(",")
          end
        end
        if column_types
          new_column_types = []
          ixes.each {|ix| new_column_types << column_types[ix]}
        end
      elsif block_given?
        File.open(next_file, "w") do |fout|
          each_row_from(source) do |row|
            fout.puts row.join(",") if yield(row)
          end
        end
        new_column_types = column_types
      else
        raise "sub_table needs :columns or a predicate block"
      end
      new_table = Table.new(new_file_stream, column_names)
      if column_types
        new_table.set_types(new_column_types)
      end
      new_table
    end
    
    def group_by(options=nil)
      if block_given?
        group = Grouping.new(column_names, file_stream.working_dir)
        source = file_stream.current
        each_row_from(source) do |row|
          key = yield row
          group.file(key).puts row.join(",")
        end
        group.close
        group.set_column_types(column_types)
        group
      elsif options and options.is_a?(Hash) and columns = options[:columns]
        group = Grouping.new(column_names, file_stream.working_dir)
        column_table = sub_table(:columns => columns)
        column_table.uniq
        distinct_values = column_table.to_a
        ixes = columns.map {|col| column_ix(col) }
        source = file_stream.current
        each_row_from(source) do |row|
          key = ixes.map {|ix| row[ix]}
          group.file(key).puts row.join(",")
        end
        group.close
        group.set_column_types(column_types)
        group
      else
        raise "Timber::Table#group_by requires a block or :columns option"
      end
    end
    
    private
    
    def executor
      @executor ||= RemoteExecutor.new("localhost")
    end
    
    def column_ix(column_name)
      ix = @column_names.index(column_name)
      raise "don't know column #{column_name}" unless ix
      ix
    end
    
    def self.cast_value(value, type)
      case type
      when :string
        value
      when :int
        value.to_i
      when :float
        value.to_f
      end
    end
    
    def each_row_from(file)
      File.open(file) do |from|
        while line = from.gets
          bits = line.chomp.split(",")
          if column_types
            typed_bits = []
            bits.zip(column_types) do |bit, type|
              typed_bits << Table.cast_value(bit, type)
            end
            yield typed_bits
          else
            yield bits
          end
        end
      end
    end
  end
end