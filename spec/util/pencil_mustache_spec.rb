require_relative '../spec_helper'

require 'wright/util/pencil_mustache'

describe Wright::Util::PencilMustache do
  describe 'render' do
    it 'should render mustache templates' do
      template = "foo: {{foo}}\n"
      hash = { foo: 'FOO' }
      expected = "foo: FOO\n"
      actual = Wright::Util::PencilMustache.new.render(template, hash)
      actual.must_equal expected
    end
  end
end
