module FayeRailsPrivate
  module ViewHelpers

    def faye_subscribe(channel, options = {})
      subscription = FayeRailsPrivate.subscription options.merge(:channel => channel)
      content_tag "script", :type => "text/javascript" do
        raw("FayePrivate.sign(#{subscription.to_json});")
      end
    end
  end
end