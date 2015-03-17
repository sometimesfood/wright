require 'optparse'
require 'wright'

$main = self

module Wright
  class CLI
    # @todo Show usage if no arguments given
    def run(argv)
      @parser = OptionParser.new do |opts|
        opts.on_tail('-v', '--version', 'Show wright version') do
          puts "wright version #{Wright::VERSION}"
          return
        end
      end

      # use OptionParser#order instead of #parse so CLI#run does not
      # consume --arguments passed to wright scripts
      arguments = @parser.order(argv)

      ARGV.shift

      $main.extend Wright::DSL
      load arguments.first unless arguments.empty?
    end
  end
end
