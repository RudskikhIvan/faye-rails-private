module FayeRailsPrivate
  class FayeExtension

    def incoming(message, callback)
      if message["channel"] == "/meta/subscribe"
        FayeRailsPrivate.authenticate_subscribe(message)
      elsif message["channel"] !~ %r{^/meta/}
        FayeRailsPrivate.authenticate_publish(message)
      end
      callback.call(message)
    end

  end
end