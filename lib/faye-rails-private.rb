require 'faye-rails-private/engine'
require 'active_support/configurable'

module FayeRailsPrivate
  include ActiveSupport::Configurable

  class ConfigurationError < StandardError; end

  configure do |config|
    config.secret_key = ENV["FAYE_PRIVATE_KEY"]

    config.token_generator = proc do |options = {}|
      Digest::MD5.hexdigest([FayeRailsPrivate.config.secret_key, options[:channel], options[:timestamp]].join('-'))
    end

    config.defender = proc do |message|
      channel =  message['channel'] == '/meta/subscribe' ? message['subscription'] : message['channel']
      token = FayeRailsPrivate.generate_token(:channel => channel, :timestamp => message['auth']['timestamp'])
      if ( message['auth']['token'] rescue nil) != token
        'Incorrect token.'
      end
    end

  end

  def self.generate_token(options = {})
    if ( generator = self.config.token_generator ).blank?
      raise ConfigurationError, 'No generate_token option specified. Check configuration'
    end
    if generator.is_a? Proc
      generator.call options
    elsif generator.respond_to? :generate
      generator.generate options
    else
      raise ConfigurationError, 'generate_token option is incorrect. It must be a proc or must have generate method'
    end
  end

  def self.subscription(options = {})
    sub = options.merge(:timestamp => (Time.now.to_f * 1000).round)
    sub[:token] = generate_token sub
    sub
  end

  def self.authenticate_subscribe(message)
    if ( defender = self.config.subscribe_defender || self.config.defender ).blank?
      raise ConfigurationError, 'No subscribe_defender option specified. Check configuration'
    end
    authenticate(message, defender)
  end

  def self.authenticate_publish(message)
    if ( defender = self.config.publish_defender || self.config.defender ).blank?
      raise ConfigurationError, 'No publish_defender option specified. Check configuration'
    end
    authenticate(message, defender)
  end

  private

  def self.token_expired?(message)
    timestamp = message['auth']['timestamp'] rescue 0
    timestamp < ((Time.now.to_f - config.token_expiration)*1000).round if config.token_expiration
  end

  def self.authenticate(message, defender)
    if token_expired?(message)
      message['error'] = 'Token has expired'
    elsif defender.is_a?(Proc) and ( error = defender.call(message) )
      message['error'] = error
    elsif defender.respond_to?(:protect) and ( error = defender.protect(message) )
      message['error'] = error
    end
  end

end
