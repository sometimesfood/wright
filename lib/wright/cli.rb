require 'optparse'
require 'wright'

module Wright
  class CLI
    def run(argv)
      @parser = OptionParser.new do |opts|
        opts.on_tail('-v', '--version', 'Show wright version') do
          puts "wright version #{Wright::VERSION}"
          return
        end
      end
      @parser.parse!(argv)
    end
  end
end
