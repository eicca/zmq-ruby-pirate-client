$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'zmq_pirate_client/version'

Gem::Specification.new do |s|
  s.name          = 'zmq_pirate_client'
  s.version       = ZMQPirateClient::Version::STRING
  s.platform      = Gem::Platform::RUBY
  s.summary       = 'Ruby client for pirate patterns using zeromq.'
  s.homepage      = 'http://github.com/eicca'
  s.email         = 'wtltl2@gmail.com'
  s.authors       = ['Mikhail Dyakov']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'ffi-rzmq'
  s.add_dependency 'activesupport', '~> 3.0'

  s.add_development_dependency 'celluloid-zmq'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-collection_matchers'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'pry'
end
