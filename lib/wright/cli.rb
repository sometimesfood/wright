require 'optparse'
require 'wright'

module Wright
  # Wright command-line interface.
  class CLI
    def initialize(main)
      @commands = []
      @requires = []
      @main = main
      set_up_parser
    end

    # Runs a wright script with the supplied arguments.
    #
    # @param argv [Array<String>] the arguments passed to bin/wright
    def run(argv)
      arguments = parse(argv)
      return if @quit

      Wright.activate_dry_run if @dry_run
      Wright.log.level = @log_level if @log_level
      @main.extend Wright::DSL
      @requires.each { |r| require r }

      run_script(arguments)
    end

    private

    attr_reader :commands, :requires, :dry_run, :log_level

    def parse(argv)
      # use OptionParser#order! instead of #parse! so CLI#run does not
      # consume --arguments passed to wright scripts
      @parser.order!(argv)
    end

    def run_script(arguments)
      if @commands.empty? && arguments.any?
        script = File.expand_path(arguments.shift)
        load script
      else
        commands = @commands.empty? ? $stdin.read : @commands.join("\n")
        @main.instance_eval(commands, '<main>', 1)
      end
    end

    def set_up_parser
      @parser = OptionParser.new
      set_up_command_option
      set_up_require_option
      set_up_dry_run_option
      set_up_verbosity_options
      set_up_version_option
    end

    def set_up_command_option
      @parser.on('-e COMMAND', 'Run COMMAND') do |e|
        @commands << e
      end
    end

    def set_up_require_option
      @parser.on('-r LIBRARY',
                 'Require LIBRARY before running the script') do |r|
        @requires << r
      end
    end

    def set_up_dry_run_option
      @parser.on('-n', '--dry-run', 'Enable dry-run mode') do
        @dry_run = true
      end
    end

    def set_up_verbosity_options
      @parser.on('-v', '--verbose', 'Increase verbosity') do
        @log_level = Wright::Logger::DEBUG
      end

      @parser.on('-q', '--quiet', 'Decrease verbosity') do
        @log_level = Wright::Logger::ERROR
      end
    end

    def set_up_version_option
      @parser.on_tail('--version', 'Show wright version') do
        puts "wright version #{Wright::VERSION}"
        @quit = true
      end
    end
  end
end
