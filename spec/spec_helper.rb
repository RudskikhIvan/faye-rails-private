require 'rubygems'
require 'bundler/setup'
require 'rails/engine'
require 'faye-rails-private'
require 'pry'
Bundler.require(:default)



RSpec.configure do |config|

  config.before :each do
    FayeRailsPrivate.configure do |config|
      config.secret_key = 'FAYE_PRIVATE_KEY'
      config.token_generator = proc{|options| 'GENERATED_TOKEN' }
      config.subscribe_defender = nil
      config.publish_defender = nil
      config.defender = proc{|options| nil}
    end
  end
end