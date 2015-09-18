require_relative '../spec_helper'

require 'wright/util/mustache_renderer'

describe Wright::Util::MustacheRenderer do
  describe 'render' do
    it 'should render mustache templates' do
      template = "foo: {{foo}}\n"
      hash = { foo: 'FOO' }
      renderer = Wright::Util::MustacheRenderer.new(hash)
      expected = "foo: FOO\n"
      actual = renderer.render(template)
      actual.must_equal expected
    end

    it 'should throw exceptions when encountering undefined names' do
      skip unless defined?(Mustache)
      template = '{{undefined_name}}'
      hash = {}
      renderer = Wright::Util::MustacheRenderer.new(hash)
      -> { renderer.render(template) }.must_raise Mustache::ContextMiss
    end

    it 'should delegate rendering templates to Mustache' do
      template = "foo: {{foo}}\n"
      hash = { foo: 'FOO' }
      mustache_class_double = Minitest::Mock.new
      mustache_object_double = Minitest::Mock.new
      mustache_class_double.expect(:new, mustache_object_double)
      mustache_object_double.expect(:raise_on_context_miss=, true, [true])
      mustache_object_double.expect(:render, nil, [template, hash])

      Object.stub_const(:Mustache, mustache_class_double) do
        Wright::Util::MustacheRenderer.new(hash).render(template)
      end
      mustache_class_double.verify
      mustache_object_double.verify
    end

    it 'should fall back to pencil_mustache if Mustache is not available' do
      template = "foo: {{foo}}\n"
      hash = { foo: 'FOO' }
      mustache_class_double = Minitest::Mock.new
      mustache_object_double = Minitest::Mock.new
      mustache_class_double.expect(:new, mustache_object_double)
      mustache_object_double.expect(:render, nil, [template, hash])

      Object.stub_remove_const(:Mustache) do
        Wright::Util.stub_const(:PencilMustache, mustache_class_double) do
          Wright::Util::MustacheRenderer.new(hash).render(template)
        end
      end
      mustache_class_double.verify
      mustache_object_double.verify
    end
  end
end
