require "rake/gempackagetask"
require File.dirname(__FILE__) + "/lib/timber"

spec = Gem::Specification.new do |s|
  s.name              = "timber"
  s.summary           = "Turn your logs into useful timber."
  s.author            = "Songkick"
  s.email             = "developers@songkick.com"
  s.homepage          = "http://www.songkick.com"

  s.version           = Timber::VERSION
  
  s.has_rdoc          = false
  s.files             = %w(Rakefile README) + 
                          Dir.glob("spec/**/*") + 
                          Dir.glob("lib/**/*") + 
  s.require_paths     = ["lib"]

  s.add_development_dependency("rspec")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end
