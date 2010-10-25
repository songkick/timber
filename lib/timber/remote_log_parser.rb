
module Timber
  class RemoteLogParser
    def self.posix_type=(val)
      @posix_type = val
    end
    
    def self.posix_type
      @posix_type || :linux
    end

    attr_reader :server, :file_glob, :file_stream
    
    # file_glob should be an absolute path.
    def initialize(server, file_glob, remote_working_dir)
      @server      = server
      @file_glob   = file_glob
      @file_stream = FileStream.new(executor, remote_working_dir)
      if any_zipped_files? and not all_zipped_files?
        raise "mixed zipped and not zipped log files. Can't proceed."
      end
    end
    
    def files
      @files ||= executor.ssh("ls #{file_glob}").split("\n")
    end
    
    def grep(pattern, options=nil)
      options ||= {}
      limit = options.delete(:limit)
      bin = all_zipped_files? ? "zgrep" : "grep"
      source_files, destination_file = source_and_destination
      if limit
        cmd = "#{bin} \"#{pattern}\" #{source_files} | head -n #{limit} > #{destination_file} || echo done"
      else
        cmd = "#{bin} \"#{pattern}\" #{source_files} > #{destination_file} || echo done"
      end
      executor.ssh(cmd)
    end
    
    def extract(pattern, column_names, local_working_dir)
      source_file, destination_file = source_and_destination
      ruby = "fin = File.open(\"#{source_file}\"); while line = (fin.readline rescue nil); match = /#{pattern.source}/.match(line); if match; puts match.captures.join(\",\"); end; end"
      executor.ruby_into(ruby, destination_file)
      new_file_stream = FileStream.new(RemoteExecutor.new("localhost"), local_working_dir)
      local_destination_file = new_file_stream.next_file
      executor.scp(destination_file, local_destination_file)
      Table.new(new_file_stream, column_names)
    end
    
    def look(prefix)
      source_files, destination_file = source_and_destination
      options = RemoteLogParser.posix_type == :linux ? " -b " : ""
      cmd = "look #{options} \"#{RemoteExecutor.escape_quotes(prefix)}\" #{source_files} > #{destination_file}"
      executor.ssh(cmd)
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
    
    def clean
      file_stream.files.each do |fn|
        executor.ssh("rm #{fn}")
      end
    end
    
    private
    
    def source_and_destination
      if parsed_original_files?
        return file_stream.current, file_stream.next_file
      else
        return file_glob,           file_stream.next_file
      end
    end
    
    def executor
      @executor ||= RemoteExecutor.new(server)
    end
  end
end