require 'optparse'
require 'wright'

$main = self

module Wright
  class CLI
    def initialize
      @commands = []
      @parser = OptionParser.new do |opts|
        opts.on('-e COMMAND', 'Run COMMAND') do |e|
          @commands << e
        end

        opts.on_tail('-v', '--version', 'Show wright version') do
          puts "wright version #{Wright::VERSION}"
          @quit = true
        end
      end
    end

    def run(argv)
      arguments = parse(argv)
      return if @quit

      $main.extend Wright::DSL

      if @commands.empty?
        script = arguments.shift
        load script if script
      else
        eval(@commands.join("\n"), $main.send(:binding), '<main>', 1)
      end
    end

    private

    attr_reader :commands

    def parse(argv)
      # use OptionParser#order! instead of #parse! so CLI#run does not
      # consume --arguments passed to wright scripts
      @parser.order!(argv)
    end
  end
end
