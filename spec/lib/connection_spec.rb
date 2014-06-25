require 'spec_helper'

describe ZMQPirateClient::Connection do

  after do
    # Remove client cache from the module.
    ZMQPirateClient::Connection.instance_variable_set(:@client, nil)
  end

  describe "delegation" do
    let(:dummy_client) { double('client') }

    before do
      ZMQPirateClient::Connection.instance_variable_set(:@client, dummy_client)
    end

    it "deleages `send_message` method to the client" do
      expect(dummy_client).to receive(:send_message).with('foo').once
      ZMQPirateClient::Connection.send_message('foo')
    end

    it "deleages `send_message!` method to the client" do
      expect(dummy_client).to receive(:send_message!).with('foo').once
      ZMQPirateClient::Connection.send_message!('foo')
    end
  end

  describe '.client' do
    subject { ZMQPirateClient::Connection.client }

    let(:dummy_client) { double('client') }

    before do
      allow(ZMQPirateClient::Connection).to receive(:initialize_client).and_return(dummy_client)
    end

    it { should eq(dummy_client) }

    it 'lazily evaluates the client instance' do
      expect { subject }.to change { ZMQPirateClient::Connection.instance_variable_get(:@client) }
        .from(nil).to(dummy_client)
    end
  end

  describe '.configure' do
    let(:client) { ZMQPirateClient::Connection.client }

    before do
      ZMQPirateClient::Connection.configure do |config|
        config.host = '8.8.8.8'
        config.port = '100500'
        config.retries = 5
      end
    end

    it 'sets provided configuration to the client' do
      expect(client.instance_variable_get(:@address)).to eq('tcp://8.8.8.8:100500')
      expect(client.instance_variable_get(:@retries)).to eq(5)
      expect(client.instance_variable_get(:@timeout)).to eq(30)
    end
  end

end
