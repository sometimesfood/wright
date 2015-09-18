require_relative '../spec_helper'

require 'wright/util/file_renderer'

describe Wright::Util::FileRenderer do
  describe 'render' do
    before(:each) do
      @template_files = {
        'foo.erb' => '<%= foo %>',
        'foo.mustache' => '{{foo}}'
      }
    end

    after(:each) { FakeFS::FileSystem.clear }

    it 'should render template files' do
      renderer = Wright::Util::FileRenderer.new(foo: 'FOOBAR')
      FakeFS do
        @template_files.each do |filename, template|
          File.write(filename, template)
          expected = 'FOOBAR'
          actual = renderer.render(filename)
          actual.must_equal expected
        end
      end
    end
  end
end
