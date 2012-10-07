require 'fakefs/safe'
require 'wright/logger'

class FakeFS::File
  def self.write(filename, file_content)
    File.open(filename, 'w') { |f| f.write(file_content) }
  end
end

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
    def self.dump
      @config_hash.clone
    end
    def self.restore(hash)
      @config_hash = hash
    end
  end
end

def reset_logger(log_level = Wright::Logger::DEBUG)
  Wright.log = Wright::Logger.new
  Wright.log.formatter = Wright::Logger::Formatter.new
  Wright.log.level = log_level
end

require 'minitest/spec'
require 'minitest/autorun'
