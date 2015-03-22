require_relative 'spec_helper'

require 'wright/cli'
require 'wright/version'

describe Wright::CLI do
  before(:each) do
    @cli = Wright::CLI.new
    @cli_dir = File.expand_path('../cli', __FILE__)
  end

  describe '#parse' do
    before(:each) { Wright::CLI.send(:public, :parse) }
    after(:each) { Wright::CLI.send(:private, :parse) }

    it 'parses -e COMMAND' do
      argv = %w(-e foo -e bar -- --baz)
      @cli.parse(argv).must_equal %w(--baz)
      @cli.send(:commands).must_equal %w(foo bar)
    end
  end

  describe '#run' do
    it 'parses --version' do
      argv = ['--version']
      expected = "wright version #{Wright::VERSION}\n"

      -> { @cli.run(argv) }.must_output expected
    end

    it 'loads files' do
      argv = [File.join(@cli_dir, 'shebang.rb')]
      expected = 'loaded shebang.rb'
      -> { @cli.run(argv) }.must_output expected
    end

    it 'evals commands' do
      argv = ['-e print :foo']
      -> { @cli.run(argv) }.must_output 'foo'
    end
  end
end
