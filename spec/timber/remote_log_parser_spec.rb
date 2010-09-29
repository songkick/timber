
require 'spec_helper'

describe Timber::RemoteLogParser do
  before do
    @remote_log_parser = Timber::RemoteLogParser.new("localhost", File.dirname(__FILE__) + "/../fixtures/*.log")
  end
  
  it "should respond to server" do
    @remote_log_parser.server.should == "localhost"
  end
  
  it "should tell you the files" do
    @remote_log_parser.files.map {|fn| File.basename(fn)}.should == %w(foo bar)
  end
end