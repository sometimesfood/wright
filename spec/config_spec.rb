require_relative 'spec_helper'

require 'wright/config'

describe Wright::Config do
  before(:each) do
    Wright::Config.clear
  end

  it 'should behave like a Hash' do
    Wright::Config.size.must_equal 0
    Wright::Config[:foo] = :bar
    Wright::Config[:bar] = :baz
    Wright::Config[:foo].must_equal :bar
    Wright::Config[:bar].must_equal :baz
    Wright::Config.size.must_equal 2
  end

  it 'should handle nested keys' do
    Wright::Config[:foo] = { :bar => :baz }
    Wright::Config.has_nested_key?(:foo, :bar).must_equal true
    Wright::Config.has_nested_key?(:foo, :bar, :qux).must_equal false
    Wright::Config.has_nested_key?(:nonexistent).must_equal false
    Wright::Config.has_nested_key?(:nonexistent1, :nonexistent2).must_equal false
  end
end
