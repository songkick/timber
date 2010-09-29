
module Timber
  class RemoteExecutor
    include Helpers
    
    attr_reader :server, :user
    
    def initialize(server)
      @server = server
    end
    
    def ssh(cmd)
      puts "[ssh] #{ssh_cmd(cmd)}" if Timber.debug?
      bash(ssh_cmd(cmd))
    end
    
    def ruby(ruby)
      puts "[ruby] #{ruby}" if Timber.debug?
      ssh(ruby_command(ruby))
    end
    
    def bash(cmd)
      %x{#{cmd}}
    end
    
    private
    
    def escape_quotes(string)
      string.gsub("\\", "\\\\\\\\").gsub("\"", "\\\"")
    end
    
    def ssh_cmd(cmd)
      "ssh #{remote_user}@#{server} \"#{escaped_cmd(cmd)}\""
    end
    
    def escaped_cmd(cmd)
      escape_quotes(cmd)
    end
    
    def ruby_command(ruby)
      "ruby -e \"#{escape_quotes(ruby)}\""
    end
        
    def remote_user
      Etc.getlogin
    end
  end
end