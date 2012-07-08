begin
  require 'simplecov'
  if ENV['COVERAGE']
    SimpleCov.start do
      add_filter '/spec/'
      add_filter '/vendor/'
    end
  end
rescue LoadError
end

# extend Wright::Config to pass on clear for tests
module Wright
  class Config
    def self.clear
      @config_hash.clear
    end
  end
end

require 'minitest/spec'
require 'minitest/autorun'
