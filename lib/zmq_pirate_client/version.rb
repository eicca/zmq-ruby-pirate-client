module ZMQPirateClient
  VERSION = "0.0.1".freeze

  module Version
    version = VERSION.to_s.split(".").map { |i| i.to_i }
    MAJOR = version[0]
    MINOR = version[1]
    PATCH = version[2]
    STRING = "#{MAJOR}.#{MINOR}.#{PATCH}"
  end
end
