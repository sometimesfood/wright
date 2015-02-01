require_relative 'spec_helpers/fake_capture3'

require 'ostruct'
require 'fakefs/safe'
require 'wright/logger'

begin
  require 'simplecov'
  if ENV['COVERAGE']
    SimpleCov.start do
      add_filter '/spec/'
      add_filter '/vendor/'
      add_filter '/.bundle/'
    end
  end
end

module Wright
  # extend Wright::Config to pass on clear for tests
  class Config
    class << self
      attr_accessor :config_hash
    end
  end
end

def reset_logger(log_level = Wright::Logger::DEBUG)
  Wright::Config[:log] = { colorize: false }
  Wright.log = Wright::Logger.new
  Wright.log.formatter = Wright::Logger::Formatter.new
  Wright.log.level = log_level
end

reset_logger(Wright::Logger::FATAL)

require 'minitest/autorun'
