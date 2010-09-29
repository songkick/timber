
require 'spec_helper'

describe Timber::Grouping do
  describe "constructing a grouping" do
    it "should let you add stuff" do
      grouping = Timber::Grouping.new([:name, :age], working_dir)
      grouping.file("developers").puts "Dan, 28"
      grouping.file("developers").puts "Robin, 23"
      grouping.file("qa").puts "Brooke, 28"
      grouping.close
      
      grouping.keys.should == ["developers", "qa"]
      grouping.table("developers").length.should == 2
      grouping.table("qa").length.should == 1
    end
  end

end