
require File.dirname(__FILE__) + "/../lib/timber"

def fixtures_dir
  File.expand_path(File.dirname(__FILE__)) + "/fixtures"
end

def working_dir
  File.expand_path(File.dirname(__FILE__)) + "/working"
end

def create_working_dir
  FileUtils.mkdir(working_dir)
end

def remove_working_dir
  FileUtils.rm_r(working_dir)
end

Spec::Runner.configure do |config|
  config.before(:each) do
    create_working_dir
  end
  
  config.after(:each) do
    remove_working_dir
  end
end