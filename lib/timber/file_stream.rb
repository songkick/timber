
module Timber
  class FileStream
    attr_reader :executor, :working_dir, :files
    
    class EmptyError < StandardError; end
    
    def initialize(executor, working_dir)
      @executor    = executor
      @working_dir = working_dir
      @files       = []
    end
    
    def any?
      @files.any?
    end
    
    def current
      @files.last
    end
    
    def next_file
      @files << File.expand_path(random_filename, working_dir)
      @files.last
    end
    
    def random_filename
      "log-#{rand(10000000)}.tmp"
    end
    
    def length
      executor.ssh("wc -l #{current}").split(" ").first.to_i
    end
    
    def assert_not_empty
      len = length
      raise EmptyError.new if len == 0
    end
    
    def force_current(filename)
      @files << filename
    end
  end
end