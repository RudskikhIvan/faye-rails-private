$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "faye-rails-private/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "faye-rails-private"
  s.version     = FayeRailsPrivate::VERSION
  s.authors     = ["Shredder"]
  s.email       = ["shredder-rull@yandex.ru"]
  s.homepage    = "https://github.com/shredder/faye-rails-private"
  s.summary     = "Private pub/sub workflow in Faye"
  s.description = "Private pub/sub workflow in Faye"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "faye-rails"
  s.add_dependency "rails", "~> 4.2.1"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
end
