require 'forwardable'
require 'active_support/core_ext/module/attribute_accessors'

module ZMQPirateClient
  module Connection
    extend SingleForwardable

    mattr_accessor :host
    mattr_accessor :port
    mattr_accessor :retries
    mattr_accessor :timeout

    def_delegators :client, :send_message, :send_message!

    def self.client
      @client ||= initialize_client
    end

    def self.configure(&_block)
      yield self
    end

    def self.initialize_client
      # Remove nil values in order to apply defaults in client.
      opts = { host: host, port: port, retries: retries, timeout: timeout
        }.delete_if { |_, v| v.nil? }
      Client.new(opts)
    end
  end
end
