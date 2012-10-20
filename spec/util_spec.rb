require_relative 'spec_helper'

require 'wright/util'

describe Wright::Util do
  it 'should convert filenames to class names' do
    classname = Wright::Util.filename_to_classname('foo_bar/baz')
    classname.must_equal 'FooBar::Baz'
  end

  it 'should convert classes to resource names' do
    resource_name = Wright::Util.class_to_resource_name(Object)
    resource_name.must_equal 'object'
  end
end
