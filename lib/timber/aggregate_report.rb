
module Timber
  class AggregateReport
    
    HTML_PREAMBLE = <<-HTML
<html>
  <head>
    <link rel="stylesheet" href="/public/css//blueprint/screen.css" type="text/css" media="screen, projection">
    <style>
      td {
        text-align: right;
      }
      tr {
        border: 1px solid gray;
      }
      th {
        text-align: right;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <br />
HTML

    HTML_POSTAMBLE = <<-HTML
    </div>
  </body>
</html>
HTML

    def initialize(name, options)
      @name             = name
      @dir              = options.delete(:dir)
      @file             = options.delete(:file)
      @key              = options.delete(:key)
      @value_column     = options.delete(:value)
      @table            = options.delete(:table)
      @sort_column      = options.delete(:sort_column)
      @generate_columns = options.delete(:generate_columns)
    end
    
    def generate
      unless File.exist?(@dir)
        FileUtils.mkdir_p(@dir)
      end
      filename = @dir +"/" + @file + ".csv"
      generate_csv(filename)
    end
    
    def generate_csv(filename)
      File.open(filename, "w") {|fout| output_table.each {|row| fout.puts row.join(",")}}
    end
    
    def generate_html(filename)
      str = ""
      str << HTML_PREAMBLE
      str << "<h3>#{title}</h3>"
      str << output_table.sort_rows_by("total time (#{units})", :order => :descending).to_html
      str << HTML_POSTAMBLE
    end
    
    def output_table
      @output_table ||= begin
        result = []
        group = @table.group_by(:columns => @key)
        group.each do |key, sub_table|
          row = []
          row << key
          @generate_columns.each do |column_value_type, _|
            r = generate_value_from_table(sub_table, column_value_type)
            row << r
          end
          result << row.flatten
        end
        if @sort_column
          result = result.sort_by do |row|
            col = 
              @generate_columns.map {|column_value_type, _| column_value_type}.index(@sort_column) + 
              @key.length
            v = row[col].to_f
            v
          end.reverse
        end
        row = [["(all)"]*@key.length]
        @generate_columns.each do |column_value_type, _|
          r = generate_value_from_table(@table, column_value_type)
          row << r
        end
        result = [column_titles, row, *result]
        result
      end
    end
    
    def column_titles
      @key + @generate_columns.map {|type, title| title }
    end
    
    def generate_value_from_table(table, column_value_type)
      measures = table.column_values(@value_column)
      case column_value_type
      when :count
        table.length
      when :total
        Stats.sum(measures)
      when :min
        measures.min
      when :max
        measures.max
      when :mean
        Stats.mean(measures)
      when :mode
        Stats.mode(measures)
      when :median
        Stats.median(measures)
      when :lower_quartile
        Stats.quartiles(measures)[0]
      when :upper_quartile
        Stats.quartiles(measures)[-1]
      when :deviation
        Stats.deviation(measures)
      when :variance
        Stats.variance(measures)
      when :apdex_ms
        apdex(measures, 500)
      when :apdex_s
        apdex(measures, 0.5)
      else
        if column_value_type.is_a?(Array) and column_value_type.first == :decile
          decile = column_value_type.last
          Stats.decile(measures)[decile]
        else
          raise "don't know what kind of column value #{column_value_type.inspect} is"
        end
      end
    end
    
    def apdex(values, n)
      num_under_n  = 0
      num_under_4n = 0
      values.each do |val|
        if val <= n
          num_under_n += 1
        elsif val <= 4*n
          num_under_4n += 1
        end
      end
      (num_under_n.to_f + 0.5*num_under_4n.to_f)/values.length
    end
    
  end
end