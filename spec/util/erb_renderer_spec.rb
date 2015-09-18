require_relative '../spec_helper'

require 'wright/util/erb_renderer'

describe Wright::Util::ErbRenderer do
  describe 'render' do
    it 'should render ERB templates' do
      template = "foo: <%= foo %>\n"
      hash = { foo: 'FOO' }
      renderer = Wright::Util::ErbRenderer.new(hash)
      expected = "foo: FOO\n"
      actual = renderer.render(template)
      actual.must_equal expected
    end

    it 'should throw exceptions when encountering undefined names' do
      template = '<%= undefined_name %>'
      hash = {}
      renderer = Wright::Util::ErbRenderer.new(hash)
      -> { renderer.render(template) }.must_raise NameError
    end
  end
end
