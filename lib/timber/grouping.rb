
module Timber
  class Grouping
    attr_reader :file_stream, :working_dir
    
    def initialize(column_names, working_dir)
      @file_handles = {}
      @tables       = {}
      @committed    = false
      @column_names = column_names
      @working_dir  = working_dir
    end
    
    def keys
      @tables.keys
    end
    
    def table(key)
      @tables[key]
    end
    
    def file(key)
      raise if @committed
      @file_handles[key] ||= begin
        new_file_stream = FileStream.new(RemoteExecutor.new("localhost"), working_dir)
        @tables[key] = Table.new(new_file_stream, @column_names)
        @file_handles[key] = File.open(new_file_stream.next_file, "w")
      end
    end
    
    def each
      keys.each do |key|
        yield key, table(key)
      end
    end
    
    def close
      @file_handles.each do |_, file|
        file.close
      end
    end
  end
end