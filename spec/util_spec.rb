require_relative 'spec_helper'

require 'wright/util'

include Wright

describe Util do
  it 'should camelize underscored words' do
    Util::ActiveSupport.camelize('foo_bar'       ).must_equal 'FooBar'
    Util::ActiveSupport.camelize('foo_bar', false).must_equal 'fooBar'
  end

  it 'should underscore CamelCase words' do
    Util::ActiveSupport.underscore('FooBar'     ).must_equal 'foo_bar'
    Util::ActiveSupport.underscore('FooBar::Baz').must_equal 'foo_bar/baz'
  end

  it 'should find constants with a given name' do
    nonexistent = 'ThisConstant::DoesNotExist'

    Util::ActiveSupport.constantize('Wright::Util').must_equal Wright::Util
    proc { Util::ActiveSupport.constantize(nonexistent) }.must_raise(NameError)
    Util::ActiveSupport.safe_constantize(nonexistent).must_be_nil
  end

  it 'should convert filenames to class names' do
    classname = Util.filename_to_classname('foo_bar/baz')
    classname.must_equal 'FooBar::Baz'
  end

  it 'should convert classes to resource names' do
    resource_name = Util.class_to_resource_name(Object)
    resource_name.must_equal 'object'
  end
end
