require_relative 'spec_helper'

require 'wright/config'

describe Wright::Config do
  before(:each) do
    # duplicate Wright::Config for testing
    @config = Wright::Config.dup
  end

  it 'should behave like a Hash' do
    @config.size.must_equal 0
    @config[:foo] = :bar
    @config[:bar] = :baz
    @config[:foo].must_equal :bar
    @config[:bar].must_equal :baz
    @config.size.must_equal 2
  end
end
