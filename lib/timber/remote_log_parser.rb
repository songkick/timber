
module Timber
  class RemoteLogParser
    attr_reader :server, :file_glob, :file_stream
    
    # file_glob should be an absolute path.
    def initialize(server, file_glob, working_dir)
      @server      = server
      @file_glob   = file_glob
      @file_stream = FileStream.new(executor, working_dir)
      if any_zipped_files? and not all_zipped_files?
        raise "mixed zipped and not zipped log files. Can't proceed."
      end
    end
    
    def files
      @files ||= executor.ssh("ls #{file_glob}").split("\n")
    end
    
    def grep(pattern)
      bin = all_zipped_files? ? "zgrep" : "grep"
      if parsed_original_files?
        source_files     = file_stream.current
        destination_file = file_stream.next_file
      else
        source_files     = file_glob
        destination_file = file_stream.next_file
      end
      grep_cmd = "#{bin} \"#{pattern}\" #{source_files} > #{destination_file} || echo done"
      executor.ssh(grep_cmd)
    end
    
    def parsed_original_files?
      file_stream.any?
    end
    
    def any_zipped_files?
      files.any? {|fn| fn =~ /gz$/}
    end
    
    def all_zipped_files?
      files.all? {|fn| fn =~ /gz$/}
    end
    
    private
    
    def executor
      @executor ||= RemoteExecutor.new(server)
    end
  end
end