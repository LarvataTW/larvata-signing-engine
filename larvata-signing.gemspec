$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "larvata/signing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "larvata-signing"
  s.version     = Larvata::Signing::VERSION
  s.authors     = ["JackTsai"]
  s.email       = ["jacktsai@larvata.tw"]
  s.homepage    = "http://larvata.tw/"
  s.summary     = "Larvata::Signing is for signing APIs of Larvata Co.ltd.."
  s.description = "Larvata::Signing is for signing APIs of Larvata Co.ltd.."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.1.4"

  s.add_development_dependency "sqlite3"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'spring'
  s.add_development_dependency 'spring-commands-rspec'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'pry-stack_explorer'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry-remote'
  s.add_development_dependency 'forgery'
end
