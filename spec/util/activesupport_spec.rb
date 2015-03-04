require_relative '../spec_helper'

require 'wright/util/stolen_from_activesupport'

include Wright

describe Util::ActiveSupport do
  it 'should camelize underscored words' do
    Util::ActiveSupport.camelize('foo_bar').must_equal 'FooBar'
  end

  it 'should underscore CamelCase words' do
    Util::ActiveSupport.underscore('FooBar').must_equal 'foo_bar'
    Util::ActiveSupport.underscore('FooBar::Baz').must_equal 'foo_bar/baz'
  end

  it 'should find constants with a given name' do
    nonexistent = 'ThisConstant::DoesNotExist'

    Util::ActiveSupport.constantize('Wright::Util').must_equal Wright::Util
    -> { Util::ActiveSupport.constantize(nonexistent) }.must_raise(NameError)
    Util::ActiveSupport.safe_constantize(nonexistent).must_be_nil
    Util::ActiveSupport.safe_constantize(nil).must_be_nil
  end
end
