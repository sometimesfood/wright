require_relative 'spec_helper'

require 'wright/cli'

describe Wright::CLI do
  before(:each) do
    @cli = CLI.new
    @cli_dir = File.expand_path('../cli', __FILE__)
  end

  describe '#run' do
    it 'parses --version' do
      argv = '--version'
      expected = "wright version #{VERSION}\n"

      -> { @cli.run(argv) }.must_output expected
    end

    it 'loads files' do
      expected = 'loaded shebang.rb'
      lambda do
        @cli.run(File.join @cli_dir, 'shebang.rb')
      end.must_output expected
    end
  end
end
