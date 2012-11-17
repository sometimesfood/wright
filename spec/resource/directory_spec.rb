require_relative '../spec_helper'

require 'wright/resource/directory'
require 'wright/provider/directory'
require 'fileutils'

describe Wright::Resource::Directory do
  before(:each) do
    @dirname = 'foo'
  end

  after(:each) do
    FakeFS::FileSystem.clear
  end

  describe '#create!' do
    it 'should create directories' do
      FakeFS do
        dir = Wright::Resource::Directory.new(@dirname)
        dir.create!
        assert File.directory?(@dirname)
      end
    end
  end
end
