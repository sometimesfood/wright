require 'logger'

require 'wright/config'
require 'wright/util/color'

module Wright # rubocop:disable Documentation
  # Default logger for Wright.
  class Logger < ::Logger
    # @api private
    # Default formatter for Wright log messages.
    class Formatter < ::Logger::Formatter
      # This method is called by {Wright::Logger} to format log
      # messages.
      #
      # @param severity [String] the log entry's severity
      # @param _time [Time] the log entry's time stamp (ignored)
      # @param _progname [String] the log entry's program name (ignored)
      # @param message [String] the log message
      #
      # @return [String] the formatted log entry
      def call(severity, _time, _progname, message)
        log_entry = "#{severity}: #{message}\n"
        if Wright::Config[:log][:colorize]
          colorize(log_entry, severity)
        else
          log_entry
        end
      end

      private

      # ANSI-Colorizes a log message according to its severity.
      #
      # @param string [String] the log message to be colorized
      # @param severity [String] the severity of the log message
      #
      # @return [String] the colorized log message
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

    # Initializes a Logger.
    #
    # Enables log colorization if the log device is a TTY and
    # colorization was not disabled before initialization.
    #
    # @param logdev [IO] the log device used by the Logger.
    def initialize(logdev = $stdout)
      super
      Wright::Config[:log] ||= {}
      return unless Wright::Config[:log][:colorize].nil?

      Wright::Config[:log][:colorize] = logdev.tty?
    end
  end

  class << self
    # @return [Logger] the logger used by Wright
    attr_accessor :log
  end
  @log = Wright::Logger.new
  @log.formatter = Wright::Logger::Formatter.new
  @log.level = Wright::Logger::INFO
end
