require_relative 'spec_helper'

require 'wright/resource'

include Wright

describe Resource do
  before(:each) do
    # duplicate Wright::Resource for testing
    resource_module = Resource.dup
    @recipe = Class.new do
      extend resource_module
    end
    @resource_module = resource_module
  end

  it 'should register new resources at runtime' do
    resource_class = Class.new do
      def self.name; 'ResourceKlass'; end
      def initialize(name); end
    end

    @resource_module.register(resource_class)

    resource_name = Util.class_to_resource_name(resource_class)
    @recipe.must_respond_to(resource_name)
    resource = @recipe.send(resource_name)
    resource.must_be_instance_of(resource_class)
  end
end
