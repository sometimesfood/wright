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

      @main.extend Wright::DSL

      if @commands.empty?
        script = arguments.shift
        load script if script
      else
        @main.instance_eval(@commands.join("\n"), '<main>', 1)
      end
    end

    private

    attr_reader :commands

    def parse(argv)
      # use OptionParser#order! instead of #parse! so CLI#run does not
      # consume --arguments passed to wright scripts
      @parser.order!(argv)
    end

    def option_parser
      OptionParser.new do |opts|
        opts.on('-e COMMAND', 'Run COMMAND') do |e|
          @commands << e
        end

        opts.on_tail('-v', '--version', 'Show wright version') do
          puts "wright version #{Wright::VERSION}"
          @quit = true
        end
      end
    end
  end
end
