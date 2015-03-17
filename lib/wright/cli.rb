require 'optparse'
require 'wright'

$main = self

module Wright
  class CLI
    def initialize
      @commands = []
    end

    def run(argv)
      @parser = OptionParser.new do |opts|
        opts.on('-e COMMAND', 'Run COMMAND') do |e|
          @commands << e
        end

        opts.on_tail('-v', '--version', 'Show wright version') do
          puts "wright version #{Wright::VERSION}"
          return
        end
      end

      # use OptionParser#order! instead of #parse! so CLI#run does not
      # consume --arguments passed to wright scripts
      arguments = @parser.order!(argv)

      $main.extend Wright::DSL

      if @commands.empty?
        script = arguments.shift
        load script if script
      else
        eval(@commands.join("\n"), $main.send(:binding), '<main>', 1)
      end
    end
  end
end
