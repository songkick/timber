
require 'spec_helper'

describe Timber::Table do
  before do
    remote_log_parser = Timber::RemoteLogParser.new("localhost", fixtures_dir + "/*.log", working_dir)
    remote_log_parser.grep("Completed")
    @table = remote_log_parser.extract(
      /(\w+ \d\d \d\d:\d\d) Completed in (\d+)ms \[controller:(\w+) \| action:(\w+)\] \((.*)\)/, 
      [:timestamp, :duration_ms, :controller, :action, :url], 
      working_dir)
    @table.set_types([:string, :int, :string, :string, :string])
  end
  
  it "should respond to to_a" do
    @table.to_a.should == [
      ["Sep 12 13:12", 52, "users", "show", "http://www.songkick.com/users/danlucraft"],
      ["Sep 12 13:20", 856, "artists", "show", "http://www.songkick.com/artist/sonic-youth"],
      ["Sep 13 09:00", 235, "venues", "show", "http://www.songkick.com/venue/o2-academy"],
      ["Sep 13 09:00", 235, "venues", "show", "http://www.songkick.com/venue/o2-academy"]
    ]
  end
  
  it "should let you rename columns" do
    @table.rename_column(:duration_ms, :duration_millis)
    @table.column_names.should == [:timestamp, :duration_millis, :controller, :action, :url]
  end
  
  it "should let you get the column values" do
    @table.column_values(:duration_ms).should == [52, 856, 235, 235]
  end
  
  it "should let you map a column" do
    @table.map_column(:duration_ms) {|s| s.to_i*2 }
    @table.column_values(:duration_ms).should == [104, 1712, 470, 470]
  end
  
  it "should let you uniq the rows" do
    @table.uniq
    @table.column_values(:duration_ms).should == [52, 856, 235]
  end
  
  it "should let you take the top n rows" do
    @table.top(2, :duration_ms).map {|bits| bits[1]}.should == [856, 235]
  end
  
  it "should let you take the bottom n rows" do
    @table.bottom(3, :duration_ms).map {|bits| bits[1]}.should == [52, 235, 235]
  end
  
  it "should be able to specify a sub table by columns" do
    @table.sub_table(:columns => [:controller, :duration_ms]).to_a.should == [
      ["users", 52],
      ["artists", 856],
      ["venues", 235],
      ["venues", 235]
    ]
  end
  
  it "should be able to specify a sub table with a predicate" do
    @table.sub_table {|row| row[1] % 2 == 0}.to_a.should == [
      ["Sep 12 13:12", 52, "users", "show", "http://www.songkick.com/users/danlucraft"],
      ["Sep 12 13:20", 856, "artists", "show", "http://www.songkick.com/artist/sonic-youth"]
    ]
  end
  
  it "should let you group by a tranformation of the rows" do
    grouping = @table.group_by {|row| row[1] % 2 }
    grouping.should be_an_instance_of(Timber::Grouping)
    grouping.keys.should == [0, 1]
  end
  
  it "should let you group by all distinct values of a subset of the columns" do
    grouping = @table.group_by(:columns => [:controller, :action])
    grouping.should be_an_instance_of(Timber::Grouping)
    grouping.keys.sort.should == [["artists", "show"], ["users", "show"], ["venues", "show"]]
    grouping.table(["venues", "show"]).to_a.should == [
      ["Sep 13 09:00", 235, "venues", "show", "http://www.songkick.com/venue/o2-academy"],
      ["Sep 13 09:00", 235, "venues", "show", "http://www.songkick.com/venue/o2-academy"]
    ]
  end
end










