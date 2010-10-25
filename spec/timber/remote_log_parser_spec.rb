
require 'spec_helper'

describe Timber::RemoteLogParser do
  before do
    @remote_log_parser = Timber::RemoteLogParser.new("localhost", fixtures_dir + "/*.log", working_dir)
  end
  
  it "should respond to server" do
    @remote_log_parser.server.should == "localhost"
  end
  
  it "should fetch a file list on demand" do
    @remote_log_parser.files.map {|fn| File.basename(fn)}.sort.should == %w(bar.log foo.log)
  end
  
  it "should not be happy with mixed file types" do
    lambda {
      Timber::RemoteLogParser.new("localhost", fixtures_dir + "/*", working_dir)    
    }.should raise_error
  end
  
  describe "logfile grepping" do
    it "should let you grep the original log files" do
      @remote_log_parser.grep("Completed")
      @remote_log_parser.file_stream.length.should == 4
    end
    
    it "should let you limit the grep" do
      @remote_log_parser.grep("Completed", :limit => 2)
      @remote_log_parser.file_stream.length.should == 2
    end
    
    it "should let you grep the generated files" do
      @remote_log_parser.grep("Random")
      @remote_log_parser.grep("ian")
      @remote_log_parser.file_stream.length.should == 0
    end
    
    it "should let you grep zipped files" do
      @remote_log_parser = Timber::RemoteLogParser.new("localhost", fixtures_dir + "/*.log.gz", working_dir)
      @remote_log_parser.grep("saleandro")
      @remote_log_parser.file_stream.length.should == 1
    end
    
    it "should clean up any temporary files" do
      @remote_log_parser.grep("saleandro")
      @remote_log_parser.clean
      Dir[working_dir + "/*.tmp"].length.should == 0
    end
  end
  
  describe "logfile looking" do
    it "should let you look in the original log files" do
      @remote_log_parser.look("Sep 12 13:1")
      @remote_log_parser.file_stream.length.should == 2
    end
  end
  
  describe "extraction" do
    it "should let you extract regex groups into a local table" do
      @remote_log_parser.grep("Completed")
      table = @remote_log_parser.extract(/Completed in (\d+)ms/, [:duration_ms], working_dir)
      table.should be_an_instance_of(Timber::Table)
      table.column_names.should == [:duration_ms]
      table.to_a.should == [["52"], ["856"], ["235"], ["235"]]
    end
  end
end




