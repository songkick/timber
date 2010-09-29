
require 'spec_helper'

describe Timber::FileStream do
  before do
    @stream = Timber::FileStream.new(Timber::RemoteExecutor.new("localhost"), working_dir)
  end
  
  it "should not start with a filename" do
    @stream.any?.should be_false
  end
  
  describe "file properties" do
    it "should tell you the line length of a file" do
      @stream.force_current(fixtures_dir + "/foo.log")
      @stream.length.should == 5
    end
    
    it "assert_non_empty should raise an error for an empty file" do
      FileUtils.touch(working_dir + "/empty.tmp")
      @stream.force_current(working_dir + "/empty.tmp")
      @stream.length.should == 0
      lambda { @stream.assert_not_empty }.should raise_error(Timber::FileStream::EmptyError)
    end
  end
end