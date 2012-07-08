require 'logger'

require 'wright/config'
require 'wright/util/color'

module Wright
  class Logger < ::Logger
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

    def initialize(logdev = $stdout)
      super
      Wright::Config[:log] ||= {}
      if Wright::Config[:log][:colorize].nil?
        Wright::Config[:log][:colorize] = logdev.tty?
      end
    end
  end

  class << self
    attr_accessor :log
  end
  @log = Wright::Logger.new
  @log.formatter = Wright::Logger::Formatter.new
end
