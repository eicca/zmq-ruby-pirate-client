# ZeroMQ ruby pirate client

## Description
This is the ruby zmq client for the various pirate patterns described in [zmq documentation](http://zguide.zeromq.org/page:all#Client-Side-Reliability-Lazy-Pirate-Pattern).

You can find example server for ruby in spec folder (using celluloid) or for nodejs in other repo: [TODO](http://todo.example)

The client and server are communicating over 0mq protocol using tcp.

## Usage
Create a new instance of the client:
```
> client = ZZMQPirateClient::Client.new(port:5566, retries: 3, timeout: 100)
```

All parameters are optional.
The default parameters are:
```
host: '0.0.0.0', port: 5567, retries: 2, timeout: 30
```

After creating the client, you can query your server with messages:
```
> client.send_message('foo')
=> "bar"
```

If an error occurs during the method call, `send_message` will return `nil`.

There's also bang version of this method: `send_message!` which raises the corresponing error.

### Usage with Rails
Create file `config/initializers/your_zmq_client.rb`:
```
ZMQPirateClient::Connection.configure do |config|
  config.host = 'some_host'
  config.port = 'some_port'
end
```
This will pass the configuration to the `ZMQPirateClient::Connection` module.
The configuration options, which are equal to `nil` or which are not specified, will be overwrited by the default options of the client (see above).

The module `ZMQPirateClient::Connection` will lazy evaluate the client instance, so the client will use a
different connection in a forking environment (see: [the passenger docs](http://www.modrails.com/documentation/Users%20guide%20Apache.html#_how_it_works)).

In a Rails app you can get an access to the client and its methods via the `ZMQPirateClient::Connection` module:
```
data = ZMQPirateClient::Connection.send_message('foo')

non_nil_data = ZMQPirateClient::Connection.send_message!('foo')

client_instance = ZMQPirateClient::Connection.client
```

## Requirements
* ruby >= 1.9
* [ZeroMQ](http://zeromq.org/) library >= 3

The ZeroMQ library must be installed on your system in a well-known location like `/usr/local/lib`. This is the default for new ZeroMQ installs.

## Installation
Make sure the ZeroMQ library is already installed on your system. For mac you can install it easily with the brew:
```
brew install zeromq
```

Then add the gem to your `Gemfile` and run `bundle install`.

## Tests
```
rspec
```
