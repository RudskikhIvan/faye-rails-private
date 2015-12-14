FayeRailsPrivate.configure do |config|

  config.secret_key = ENV["FAYE_PRIVATE_KEY"]

  #config.token_expiration = 6.hours

  # config.token_generator = proc do |options = {}|
  #   Digest::MD5.hexdigest([FayeRailsPrivate.options.secret_key, options[:channel], options[:timestamp]].join('-'))
  # end

  # config.defender = proc do |message|
  #   channel =  message['channel'] == '/meta/subscribe' ? message['subscription'] : message['channel']
  #   token = FayeRailsPrivate.generate_token(:channel => channel, :timestamp => message['auth']['timestamp'])
  #   if ( message['auth']['token'] rescue nil) != token
  #     'Incorrect signature.'
  #   end
  # end

end