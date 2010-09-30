


require 'spec_helper'

describe Timber::AggregateReport do
  context "A controller/action report" do
    before do
      remote_log_parser = Timber::RemoteLogParser.new("localhost", fixtures_dir + "/*.log", working_dir)
      remote_log_parser.grep("Completed")
      @table = remote_log_parser.extract(
        /(\w+ \d\d \d\d:\d\d) Completed in (\d+)ms \[controller:(\w+) \| action:(\w+)\] \((.*)\)/, 
        [:timestamp, :duration_ms, :controller, :action, :url], 
        working_dir)
      @table.set_types([:string, :int, :string, :string, :string])
      
      Timber::AggregateReport.new(
        "Action breakdown for last hour",
        :dir   => "#{working_dir}/timber_reports/poller",
        :files => ["_last_hour"],
        :key   => [:klass, :listen_block],
        :value => :duration_ms,
        :table  => @table
      ).generate
    end
    
    it "should create a csv file" do
      File.exist?("#{working_dir}/timber_reports/skweb/_last_hour.csv")
    end
  end
end