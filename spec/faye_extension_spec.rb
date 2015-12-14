require 'spec_helper'

describe FayeRailsPrivate::FayeExtension do

  before do
    FayeRailsPrivate.config.defender = proc{|message| message['error'] = 'Test error'}
  end

  let(:error_callback){ ->(message){ expect(message['error']).to eq('Test error') } }
  let(:success_callback){ ->(message){ expect(message['error']).to_not be } }

  it 'set error for subscribe message' do
    FayeRailsPrivate::FayeExtension.new.incoming({"channel" => "/meta/subscribe"}, error_callback)
  end

  it 'set error for any not meta message' do
    FayeRailsPrivate::FayeExtension.new.incoming({"channel" => "/messages"}, error_callback)
    FayeRailsPrivate::FayeExtension.new.incoming({"channel" => "/users"}, error_callback)
  end

  it 'set not set error for meta messages' do
    FayeRailsPrivate::FayeExtension.new.incoming({"channel" => "/meta/handshake"}, success_callback)
    FayeRailsPrivate::FayeExtension.new.incoming({"channel" => "/meta/connect"}, success_callback)
  end

end