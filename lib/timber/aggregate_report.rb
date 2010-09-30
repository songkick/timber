
module Timber
  class AggregateReport
    def initialize(name, options)
      @name             = name
      @dir              = options.delete(:dir)
      @file             = options.delete(:file)
      @key              = options.delete(:key)
      @value            = options.delete(:value)
      @table            = options.delete(:table)
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
      headers = column_titles
      table.group_by => 
      File.open(filename, "w") {|fout| fout.puts headers.join(",")}
    end
    
    def column_titles
      @key + @generate_columns.map {|type, title| title }
    end
  end
end