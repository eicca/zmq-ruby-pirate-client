require 'spec_helper'

describe ZMQPirateClient::Client do

  let(:client) { ZMQPirateClient::Client.new(port: 5566, retries: 3, timeout: 100) }

  before { server.async.run if server }

  after { server.stop if server }

  describe '#send_message' do
    subject { client.send_message("foo") }

    context 'when server works normally' do
      let(:server) do
        MockServer.new('tcp://0.0.0.0:5566', delay: 0, mock_response: mock_response)
      end

      context 'and responds with correct json' do
        let(:mock_response) { { foo: 'bar' }.to_json }

        it 'returns parsed json' do
          expect(subject.body).to eq('foo' => 'bar')
        end
      end

      context 'and responds with incorrect json' do
        let(:mock_response) { 'foo:bar' }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end

    context 'when server is offline' do
      let(:server) { false }

      it 'tries to reach the server several times, and then returns a nil' do
        expect(subject).to be_nil
      end
    end

    context 'when server is overloaded' do
      let(:server) { MockServer.new('tcp://0.0.0.0:5566', delay: delay_seconds) }

      context 'and response time > allowed timeout' do
        let(:delay_seconds) { 3 }

        it 'returns a nil' do
          expect(subject).to be_nil
        end
      end

      context 'and response time < allowed timeout' do
        let(:delay_seconds) { 0.15 }

        it 'returns parsed response' do
          expect(subject.body).to be_kind_of(Hash)
        end
      end

      context 'and when server responds with timeout' do
        let(:delay_seconds) { 0.5 }

        it 'able to process the next request' do
          # This will fail because of the server timeout.
          expect(client.send_message('baz')).to be_nil
          # Wait until the server can process requests again.
          sleep(0.6)
          # Set distinguishable reply to the server.
          server.response = { foo2: 'bar2' }.to_json
          # Fire the new request to the server.
          expect(client.send_message('baz2').body).to eq('foo2' => 'bar2')
        end
      end
    end
  end

  describe '#send_message!' do
    subject { client.send_message!('foo') }

    context 'when server works normally, but responds with incorrect json' do
      let(:server) { MockServer.new('tcp://0.0.0.0:5566', delay: 0, mock_response: 'foo:bar') }

      it 'raises a parse error' do
        expect { subject }.to raise_error(ZMQPirateClient::ParseError)
      end
    end

    context 'when server is offline' do
      let(:server) { false }

      it 'tries to reach the server several times, and then raises an error' do
        expect { subject }.to raise_error(ZMQPirateClient::ConnectionTimeout)
      end
    end

    context 'when server is overloaded and response time > allowed timeout' do
      let(:server) { MockServer.new('tcp://0.0.0.0:5566', delay: 3) }

      it 'raises an error' do
        expect { subject }.to raise_error(ZMQPirateClient::ConnectionTimeout)
      end
    end
  end

end
