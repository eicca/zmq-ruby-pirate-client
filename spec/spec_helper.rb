require 'simplecov'
SimpleCov.start

require 'rspec/collection_matchers'
require 'pry'
require 'zmq_pirate_client'

require 'support/mock_server'

logfile = File.open(File.expand_path('../../log/test.log', __FILE__), 'a')
Celluloid.logger = Logger.new(logfile)
