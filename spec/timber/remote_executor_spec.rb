
require 'spec_helper'

describe Timber::RemoteExecutor do
  before do
    @executor = Timber::RemoteExecutor.new("localhost")
  end
    
  describe "executing ssh commands" do
    it "should execute commands and return the result" do
      @executor.ssh("ls #{fixtures_dir}/").should == "bar.log\nfoo.log\nzipped.log.gz\n"
    end
    
    it "should escape the commands" do
      @executor.ssh("ruby -e \"p :foo\"").should == ":foo\n"
    end  
  end
  
  describe "executing ssh commands and collecting results" do
    it "should execute commands and return the result" do
      fn = working_dir + "/output1.log"
      @executor.ssh_into("ls #{fixtures_dir}/", fn)
      File.read(fn).should == "bar.log\nfoo.log\nzipped.log.gz\n"
    end
    
    it "should execute commands and return the result" do
      fn = working_dir + "/output1.log"
      @executor.ruby_into("p :foo", fn)
      File.read(fn).should == ":foo\n"
    end
  end

  describe "executing ruby" do
    it "should execute commands and return the result" do
      @executor.ruby("p :foo").should == ":foo\n"
    end
    
    it "should escape quotes" do
      @executor.ruby("p \"foo\"").should == "\"foo\"\n"
    end
    
    it "should escape quotes totally" do
      @executor.ruby("p \"fo\\\"o\"").should == "\"fo\\\"o\"\n"
    end
  end
end


