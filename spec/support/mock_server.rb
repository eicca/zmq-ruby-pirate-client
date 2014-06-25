require 'celluloid/zmq'
require 'json'

Celluloid::ZMQ.init

class MockServer
  include Celluloid::ZMQ

  # Make response accessible in order to test req-rep accordance.
  attr_accessor :response

  def initialize(address, delay: 0, mock_response: '')
    @socket = RepSocket.new
    @delay = delay
    @response = mock_response.empty? ? { foo: 'bar' }.to_json : mock_response
    connect_socket(address)
  end

  def run
    loop { async.handle_message @socket.read }
  end

  def stop
    @socket.close
  end

  private

  def handle_message(_)
    # Sleep only for the first request
    sleep(@delay) unless @slept
    @slept = true
    @socket.send(@response)
  end

  def connect_socket(address)
    @socket.bind(address)
  end
end
