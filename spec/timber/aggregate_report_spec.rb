


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
        :dir    => "#{working_dir}/reports/skweb",
        :file   => "_last_hour",
        :key    => [:controller, :action],
        :value  => :duration_ms,
        :table  => @table,
        :generate_columns => [
          [:count     , "Count"],
          [:mean      , "Mean (ms)"],
          [:median    , "Median (ms)"],
          [:deviation , "Deviation (ms)"],
          [:total,      "Total time (ms)"],
          [:apdex_ms  , "Apdex"]
        ]
      ).generate
    end
    
    def csv_filename
      "#{working_dir}/reports/skweb/_last_hour.csv"
    end
    
    it "should create a csv file" do
      File.exist?(csv_filename).should be_true
    end
    
    it "the csv file should contain the correct data" do
      File.readlines(csv_filename).map {|line| line.chomp.split(",")}.sort.should == [
        ["artists", "show", "1", "856.0", "856.0", "0.0", "856", "0.5"],
        ["controller", "action", "Count", "Mean (ms)", "Median (ms)", "Deviation (ms)", "Total time (ms)", "Apdex"],
        ["users", "show", "1", "52.0", "52.0", "0.0", "52", "1.0"],
        ["venues", "show", "2", "235.0", "235.0", "0.0", "470", "1.0"]
      ]
    end
  end
end