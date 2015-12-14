require 'spec_helper'

describe FayeRailsPrivate do

  let(:subject){ FayeRailsPrivate }
  let(:token){ 'GENERATED_TOKEN' }
  let(:timestamp){ Time.now.to_i * 1000 }

  def md5(key)
    Digest::MD5.hexdigest(key)
  end

  describe 'Configuration' do

    it 'return default settings' do
      expect( subject.config.secret_key ).to eq('FAYE_PRIVATE_KEY')
      expect( subject.config.token_generator ).to be_a(Proc)
      expect( subject.config.defender ).to be_a(Proc)
    end

  end

  describe 'Toke generation' do

    it 'generete token by setting' do
      subject.config.token_generator = proc{|options| options[:channel] + '-' + 'SECRET_KEY'}
      expect( subject.generate_token(:channel => '/messages') ).to eq '/messages-SECRET_KEY'
      expect( subject.generate_token(:channel => '/users') ).to eq '/users-SECRET_KEY'
      expect( subject.generate_token(:channel => '/events/100') ).to eq '/events/100-SECRET_KEY'

      subject.config.token_generator = proc{|options| md5( options[:channel] ) }
      expect( subject.generate_token(:channel => '/messages') ).to eq md5('/messages')
      expect( subject.generate_token(:channel => '/users') ).to eq md5('/users')
      expect( subject.generate_token(:channel => '/events/100') ).to eq md5('/events/100')
    end

  end

  describe 'Subscription hash' do


    before{ subject.config.token_generator = proc{|options| token} }

    it 'build sbscriptons hash for javascript' do

      expect(subject.subscription(:channel => '/messages')).to match({
        :channel => '/messages',
        :timestamp => a_kind_of(Integer),
        :token => token
      })

      expect(subject.subscription(:channel => '/messages', :user_id => 100)).to match({
        :channel => '/messages',
        :timestamp => a_kind_of(Integer),
        :token => token,
        :user_id => 100
      })

    end
  end

  describe 'Authenticate' do

    let(:subscribe_message)do
      {
          "channel" => "/meta/subscribe",
          "clientId" => "880cse592rx21p2c21g5eqcuaontiab",
          "subscription" => "/messages",
          "id" => "3",
          "auth" => { "token" => token, "timestamp" => timestamp }
      }
    end

    let(:message)do
      {
          "channel" => "/messages",
          "clientId" => "880cse592rx21p2c21g5eqcuaontiab",
          "id" => "e",
          "data" => {"user_id" => 100},
          "auth" => { "token" => token, "timestamp" => timestamp }
      }
    end

    describe 'Defender is Proc' do

      before(:each){ subject.config.defender = proc{|message| 'Incorrect token' if message['auth']['token'] != subject.generate_token} }

      it 'allow correct messages' do
        subject.config.token_generator = proc{|options| token}
        expect( subject.authenticate_subscribe(subscribe_message) ).to_not be
        expect( subject.authenticate_publish(message) ).to_not be
      end

      it 'protect uncorrected messages' do
        subject.config.token_generator = proc{|options| 'NEW_TOKEN'}
        expect( subject.authenticate_subscribe(subscribe_message) ).to eq('Incorrect token')
        expect( subject.authenticate_publish(message) ).to eq('Incorrect token')
      end

    end

    describe 'Defender is Class' do

      before :each do
        subject.config.defender = Class.new do
          def self.protect(message)
            'Incorrect token' if message['auth']['token'] != FayeRailsPrivate.generate_token
          end
        end
      end

      it 'allow correct messages' do
        subject.config.token_generator = proc{|options| token}
        expect( subject.authenticate_subscribe(subscribe_message) ).to_not be
        expect( subject.authenticate_publish(message) ).to_not be
      end

      it 'protect uncorrected messages' do
        subject.config.token_generator = proc{|options| 'NEW_TOKEN'}
        expect( subject.authenticate_subscribe(subscribe_message) ).to eq('Incorrect token')
        expect( subject.authenticate_publish(message) ).to eq('Incorrect token')
      end

    end

    describe 'Separated pub/sub defenders' do

      it 'allow correct messages' do
        subject.config.token_generator = proc{|options| token}
        expect( subject.authenticate_subscribe(subscribe_message) ).to_not be
        expect( subject.authenticate_publish(message) ).to_not be

        subject.config.subscribe_defender = proc{|message| 'Subscribe protected'}
        expect( subject.authenticate_subscribe(subscribe_message) ).to eq('Subscribe protected')
        expect( subject.authenticate_publish(message) ).to_not be

        subject.config.publish_defender = proc{|message| 'Publish protected'}
        expect( subject.authenticate_subscribe(subscribe_message) ).to eq('Subscribe protected')
        expect( subject.authenticate_publish(message) ).to eq 'Publish protected'

      end

    end

    describe 'Token expired' do

      before(:each){ subject.config.token_expiration = 1.hour }
      it 'protect by timstamp' do
        expect( subject.authenticate_subscribe(subscribe_message) ).to_not be
        expect( subject.authenticate_publish(message) ).to_not be

        subscribe_message = self.subscribe_message.tap{|m| m['auth']['timestamp'] = 2.hours.ago.to_i * 1000}
        expect( subject.authenticate_subscribe(subscribe_message) ).to eq('Token has expired')
        expect( subject.authenticate_publish(message) ).to_not be

        message = self.message.tap{|m| m['auth']['timestamp'] = 2.hours.ago.to_i * 1000}
        expect( subject.authenticate_subscribe(subscribe_message) ).to eq('Token has expired')
        expect( subject.authenticate_publish(message) ).to eq('Token has expired')
      end

    end

  end

end