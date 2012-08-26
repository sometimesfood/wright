require 'logger'

require 'wright/config'
require 'wright/util/color'

module Wright

  # Public: Default logger for Wright.
  class Logger < ::Logger

    # Public: Default formatter for Wright log messages.
    class Formatter < ::Logger::Formatter
      # Internal: Called by Wright::Logger to format log messages.
      #
      # severity - The String log severity.
      # time     - The time for the log entry. Ignored.
      # progname - The program name for the log entry. Ignored.
      # message  - The actual log message.
      #
      # Returns the formatted String log entry.
      def call(severity, time, progname, message)
        log_entry = "#{severity}: #{message}\n"
        if Wright::Config[:log][:colorize]
          colorize(log_entry, severity)
        else
          log_entry
        end
      end

      private
      # Internal: ANSI-Colorize a log message according to its
      # severity.
      #
      # string   - The String log message to be colorized.
      # severity - The String severity of the log message.
      #
      # Returns the colorized String.
      def colorize(string, severity)
        case severity
        when 'ERROR', 'FATAL'
          Wright::Util::Color.red(string)
        when 'WARN'
          Wright::Util::Color.yellow(string)
        when 'INFO'
          string
        else
          string
        end
      end
    end

    # Public: Initialize a Logger.
    #
    # Enables log colorization if the log device is a TTY and
    # colorization was not disabled before initialization.
    #
    # logdev - The log device used by the Logger.
    def initialize(logdev = $stdout)
      super
      Wright::Config[:log] ||= {}
      if Wright::Config[:log][:colorize].nil?
        Wright::Config[:log][:colorize] = logdev.tty?
      end
    end
  end

  class << self
    # Public: Gets/Sets Wright's Logger.
    attr_accessor :log
  end
  @log = Wright::Logger.new
  @log.formatter = Wright::Logger::Formatter.new
end
