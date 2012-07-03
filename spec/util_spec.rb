require_relative 'spec_helper'

require 'wright/util'

describe Wright::Util do
  it 'should camelize underscored words' do
    Wright::Util.camelize('foo_bar'       ).must_equal 'FooBar'
    Wright::Util.camelize('foo_bar', false).must_equal 'fooBar'
  end

  it 'should underscore CamelCase words' do
    Wright::Util.underscore('FooBar'     ).must_equal 'foo_bar'
    Wright::Util.underscore('FooBar::Baz').must_equal 'foo_bar/baz'
  end

  it 'should find constants with a given name' do
    nonexistent = 'ThisConstant::DoesNotExist'

    Wright::Util.constantize('Wright::Util').must_equal Wright::Util
    proc { Wright::Util.constantize(nonexistent) }.must_raise(NameError)
    Wright::Util.safe_constantize(nonexistent).must_be_nil
  end

  it 'should convert filenames to class names' do
    classname = Wright::Util.filename_to_classname('foo_bar/baz')
    classname.must_equal 'FooBar::Baz'
  end

  it 'should convert classes to resource names' do
    resource_name = Wright::Util.class_to_resource_name(Object)
    resource_name.must_equal 'object'
  end
end
