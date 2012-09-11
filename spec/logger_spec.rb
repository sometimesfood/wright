require_relative 'spec_helper'

require 'wright/logger'
require 'wright/config'

FORMATS = {
  info:  :green,
  warn:  :yellow,
  error: :red,
  fatal: :red
}

describe Wright::Logger do
  before(:each) do
    @config = Wright::Config.dump
    Wright::Config.clear
    @message = 'Soylent Green is STILL made out of people!'
  end

  after(:each) do
    Wright::Config.restore(@config)
  end

  it 'should enable colors on TTYs' do
    logger = Wright::Logger.new
    Wright::Config[:log][:colorize].must_equal true
  end

  it 'should disable colors if the log device is not a TTY' do
    logger = Wright::Logger.new(StringIO.new)
    Wright::Config[:log][:colorize].must_equal false
  end

  it 'should not change predefined color preferences' do
    Wright::Config[:log] = { colorize: false }
    logger = Wright::Logger.new
    Wright::Config[:log][:colorize].must_equal false
  end

  it 'should format log messages according to the config' do
    [true, false].each do |enable_color|
      Wright::Config[:log] = {colorize: enable_color}

      FORMATS.each do |severity, color|
        log_entry = "#{severity.upcase}: #{@message}\n"
        output = if enable_color && color != :none
                   Wright::Util::Color.send(color, log_entry)
                 else
                   log_entry
                 end
        proc do
          stdout = $stdout.dup
          def stdout.tty?; true; end
          logger = Wright::Logger.new(stdout)
          logger.formatter = Wright::Logger::Formatter.new
          logger.send(severity, @message)
        end.must_output output
      end
    end
  end
end
