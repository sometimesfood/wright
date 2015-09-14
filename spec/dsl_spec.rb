require_relative 'spec_helper'

require 'wright/dsl'

describe Wright::DSL do
  before(:each) do
    # duplicate Wright::DSL for testing
    dsl = Wright::DSL.dup
    @recipe = Object.new
    @recipe.extend(dsl)
    @wright_dsl = dsl
  end

  it 'should register new resources at runtime' do
    resource_class = Class.new do
      def self.name
        'ResourceKlass'
      end

      def initialize(_name, _args); end
    end

    @wright_dsl.register_resource(resource_class)

    resource_method_name = 'resource_klass'
    resource_name = 'just a name'
    @recipe.must_respond_to(resource_method_name)

    # Ruby 1.9: "0 for 1", Ruby 2: "0 for 1..2"
    error_message_re = /\Awrong number of arguments \(0 for 1(..2)?\)\Z/
    e = -> { @recipe.send(resource_method_name) }.must_raise ArgumentError
    e.message.must_match error_message_re

    resource = @recipe.send(resource_method_name, resource_name)
    resource.must_be_instance_of(resource_class)
  end

  it 'should execute the default action for a resource' do
    resource_class = Class.new do
      def self.name
        'Hello'
      end

      def initialize(name, _args = {})
        @name = name
      end

      def run_action
        puts "Hello #{@name}"
      end
    end
    @wright_dsl.register_resource(resource_class)
    resource_name = Wright::Util.class_to_resource_name(resource_class)
    -> { @recipe.send(resource_name, 'world') }.must_output("Hello world\n")
  end

  it 'should call blocks passed to a resource function' do
    resource_class = Class.new do
      def self.name
        'ResourceKlass'
      end

      def initialize(_name, _args = {}); end
    end
    @wright_dsl.register_resource(resource_class)

    resource_name = Wright::Util.class_to_resource_name(resource_class)
    block = ->(resource) { throw resource.class }

    -> { @recipe.send(resource_name, nil, &block) }.must_throw resource_class
  end

  describe '#util' do
    it 'should return a Wright::DSL::Util object' do
      @recipe.util.must_be_instance_of Wright::DSL::Util
    end
  end
end

describe Wright::DSL::Util do
  before(:each) { @util = Wright::DSL::Util.new }

  describe '#render_erb' do
    it 'should delegate rendering ERB templates to ErbRenderer' do
      erb_renderer_class_double = Minitest::Mock.new
      erb_renderer_object_double = Minitest::Mock.new
      erb_renderer_class_double.expect(:new,
                                       erb_renderer_object_double,
                                       [:hash])
      erb_renderer_object_double.expect(:render, nil, [:template])

      Wright::Util.stub_const(:ErbRenderer,
                              erb_renderer_class_double) do
        @util.render_erb(:template, :hash)
      end
      erb_renderer_class_double.verify
      erb_renderer_object_double.verify
    end
  end

  describe '#render_mustache' do
    it 'should delegate rendering mustache templates to MustacheRenderer' do
      mustache_renderer_class_double = Minitest::Mock.new
      mustache_renderer_object_double = Minitest::Mock.new
      mustache_renderer_class_double.expect(:new,
                                            mustache_renderer_object_double,
                                            [:hash])
      mustache_renderer_object_double.expect(:render, nil, [:template])

      Wright::Util.stub_const(:MustacheRenderer,
                              mustache_renderer_class_double) do
        @util.render_mustache(:template, :hash)
      end
      mustache_renderer_class_double.verify
      mustache_renderer_object_double.verify
    end
  end

  describe '#render_file' do
    it 'should delegate rendering files templates to FileRenderer' do
      file_renderer_class_double = Minitest::Mock.new
      file_renderer_object_double = Minitest::Mock.new
      file_renderer_class_double.expect(:new,
                                        file_renderer_object_double,
                                        [:hash])
      file_renderer_object_double.expect(:render, nil, [:filename])

      Wright::Util.stub_const(:FileRenderer, file_renderer_class_double) do
        @util.render_file(:filename, :hash)
      end
      file_renderer_class_double.verify
      file_renderer_object_double.verify
    end
  end
end
