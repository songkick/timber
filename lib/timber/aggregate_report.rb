
module Timber
  class AggregateReport
    def initialize(name, options)
      @name = name
      @dir = options.delete(:dir)
      @files = options.delete(:files)
      @key = options.delete(:key)
      @value = options.delete(:value)
      @table = options.delete(:table)
    end
    
    def generate
      unless File.exist?(@dir)
        FileUtils.mkdir_p(@dir)
      end
      FileUtils.touch(@dir + @files.first)
    end
  end
end