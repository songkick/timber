$:.push(File.expand_path(File.dirname(__FILE__)))

require 'timber/aggregate_report'
require 'timber/file_stream'
require 'timber/grouping'
require 'timber/remote_log_parser'
require 'timber/remote_executor'
require 'timber/table'
require 'timber/stats'

module Timber
  VERSION = "0.1.0"
  
  def self.debug?
    ENV["DEBUG"]
  end
end

