require 'optparse'
require 'wright'

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
      arguments = @parser.parse(argv)

      ARGV.shift

      load arguments.first unless arguments.empty?
    end
  end
end
