require 'open3'

require 'wright/config'
require 'wright/dry_run'
require 'wright/util/recursive_autoloader'

module Wright
  # Provider class.
  class Provider
    # Wright standard provider directory
    PROVIDER_DIR = File.expand_path('provider', File.dirname(__FILE__))

    Wright::Util::RecursiveAutoloader.add_autoloads(PROVIDER_DIR, name)

    # Initializes a Provider.
    #
    # @param resource [Resource] the resource used by the provider
    def initialize(resource)
      @resource = resource
      @updated = false
    end

    # Checks if the provider was updated since the last call to
    # {#updated?}
    #
    # @return [Bool] true if the provider was updated and false
    #   otherwise
    def updated?
      updated = @updated
      @updated = false
      updated
    end

    private

    # @api public
    # Logs an info message and runs a code block unless dry run mode
    # is active.
    #
    # @param message [String] the message that is passed to the logger
    def unless_dry_run(message)
      if Wright.dry_run?
        Wright.log.info "(would) #{message}"
      else
        Wright.log.info message
        yield
      end
    end

    # @api public
    # Checks if the provider is up-to-date, runs a code block and sets
    # `@updated` to `true` if it is not.
    #
    # @param action [String] the target action
    # @param message [String] a log message that is displayed if the
    #   provider is up-to-date
    def unless_uptodate(action, message)
      if uptodate?(action)
        Wright.log.debug message
      else
        yield
        @updated = true
      end
    end

    # @api public
    # Runs a command or fails with an error message.
    #
    # @param command [String] the command to run
    # @param args [Array<String>] the arguments that are passed to the
    #   command
    # @param error_message [String] the error message to display in
    #   case of an error
    # @raise [RuntimeError] if the command did not exit successfully
    # @return [String] the stdout output of the command
    def exec_or_fail(command, args, error_message)
      stdout, stderr, status = Open3.capture3(env, command, *args)
      return stdout if status.success?

      error = stderr.chomp
      error = stdout.chomp if error.empty?
      fail %(#{error_message}: "#{error}")
    end

    def env
      {}
    end
  end
end
