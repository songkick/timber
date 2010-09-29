
module Timber
  class RemoteLogParser
    attr_reader :server
    
    def initialize(server, file_glob)
      @server = server
      @file_glob = file_glob
    end
    
    def files
    end
  end
end