
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
    
    def ssh_into(cmd, destination_file)
      puts "[ssh] #{ssh_cmd(cmd)}" if Timber.debug?
      bash(ssh_cmd(cmd) + " > #{destination_file}")
    end
    
    def ruby_into(ruby, destination_file)
      puts "[ruby] #{ruby}" if Timber.debug?
      ssh(ruby_command(ruby) + " > #{destination_file}")
    end
    
    def bash(cmd)
      %x{#{cmd}}
    end
    
    def scp(from, to)
      scp_cmd = "scp #{remote_user}@#{server}:#{from} #{to}"
      puts "[scp] #{scp_cmd}" if Timber.debug?
      bash(scp_cmd)
    end
    
    private
    
    def escape_quotes(string)
      string.gsub("\\", "\\\\\\\\").gsub("\"", "\\\"")
    end
    
    def ssh_cmd(cmd)
      "ssh #{remote_user}@#{server} \"nice #{escaped_cmd(cmd)}\""
    end
    
    def escaped_cmd(cmd)
      escape_quotes(cmd)
    end
    
    def ruby_command(ruby)
      "nice ruby -e \"#{escape_quotes(ruby)}\""
    end
        
    def remote_user
      Etc.getlogin
    end
  end
end