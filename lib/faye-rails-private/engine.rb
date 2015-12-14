require 'faye-rails-private/faye_extension'
require 'faye-rails-private/view_helpers'

module FayeRailsPrivate
  class Engine < Rails::Engine

    initializer "faye_rails_private.view_helpers" do
      ActionView::Base.send :include, FayeRailsPrivate::ViewHelpers
    end

    initializer "faye_rails_private.add_extension" do
      FayeRails::Middleware::DEFAULTS[:extensions] = [FayeRailsPrivate::FayeExtension.new]
    end

  end
end