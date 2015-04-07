require 'optparse'
require 'wright'

module Wright
  # Wright command-line interface.
  class CLI
    def initialize(main)
      @commands = []
      @main = main
      @parser = option_parser
    end

    # Runs a wright script with the supplied arguments.
    #
    # @param argv [Array<String>] the arguments passed to bin/wright
    def run(argv)
      arguments = parse(argv)
      return if @quit

      Wright.log.level = @log_level if @log_level
      @main.extend Wright::DSL

      run_script(arguments)
    end

    private

    attr_reader :commands
    attr_reader :log_level

    def parse(argv)
      # use OptionParser#order! instead of #parse! so CLI#run does not
      # consume --arguments passed to wright scripts
      @parser.order!(argv)
    end

    def run_script(arguments)
      if @commands.empty? && arguments.any?
        script = arguments.shift
        load script
      else
        commands = @commands.empty? ? $stdin.read : @commands.join("\n")
        @main.instance_eval(commands, '<main>', 1)
      end
    end

    def option_parser
      OptionParser.new do |opts|
        opts.on('-e COMMAND', 'Run COMMAND') do |e|
          @commands << e
        end

        opts.on('-v', '--verbose', 'Increase verbosity') do
          @log_level = Wright::Logger::DEBUG
        end

        opts.on('-q', '--quiet', 'Decrease verbosity') do
          @log_level = Wright::Logger::ERROR
        end

        opts.on_tail('--version', 'Show wright version') do
          puts "wright version #{Wright::VERSION}"
          @quit = true
        end
      end
    end
  end
end
