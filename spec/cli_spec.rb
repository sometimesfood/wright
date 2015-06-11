require_relative 'spec_helper'

require 'wright/cli'
require 'wright/version'

main = self

describe Wright::CLI do
  before(:each) do
    @cli = Wright::CLI.new(main)
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

    it 'parses -r LIBRARY' do
      argv = %w(-r library1 -r library2 -rlibrary3 file.rb)
      @cli.parse(argv).must_equal %w(file.rb)
      @cli.send(:requires).must_equal %w(library1 library2 library3)
    end

    it 'parses --dry-run' do
      argv = %w(--dry-run file.rb)
      @cli.parse(argv).must_equal %w(file.rb)
      @cli.send(:dry_run).must_equal true
    end

    it 'parses --verbose' do
      argv = ['--verbose']
      @cli.parse(argv)
      @cli.send(:log_level).must_equal Wright::Logger::DEBUG
    end

    it 'parses --quiet' do
      argv = ['--quiet']
      @cli.parse(argv)
      @cli.send(:log_level).must_equal Wright::Logger::ERROR
    end
  end

  describe '#run' do
    it 'parses --version' do
      argv = ['--version']
      expected = "wright version #{Wright::VERSION}\n"
      -> { @cli.run(argv) }.must_output expected
    end

    it 'enables dry-run mode when requested to do so' do
      argv = ['--dry-run', '-e', 'print Wright.dry_run?']
      expected = 'true'
      -> { @cli.run(argv) }.must_output expected
      Wright.instance_variable_set(:@dry_run, false)
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

    it 'evals commands from $stdin' do
      argv = []
      stdin_orig = $stdin
      $stdin = StringIO.new("print :bar\ntrue")
      -> { @cli.run(argv) }.must_output 'bar'
      $stdin = stdin_orig
    end
  end
end
