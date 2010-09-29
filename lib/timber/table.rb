
module Timber
  class Table
    attr_reader :column_names
    
    def initialize(file_stream, column_names)
      @file_stream  = file_stream
      @column_names = column_names
    end
    
    def to_a
      File.readlines(@file_stream.current).map do |line|
        line.chomp.split(",")
      end
    end
  end
end