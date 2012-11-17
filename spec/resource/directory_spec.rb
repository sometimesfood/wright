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

    it 'should not change existing directories' do
      FakeFS do
        FileUtils.mkdir_p(@dirname)
        assert File.directory?(@dirname)
        dir = Wright::Resource::Directory.new(@dirname)
        dir.create!
        assert File.directory?(@dirname)
      end
    end

    it 'should raise an exception if there is a regular file at path' do
      FakeFS do
        FileUtils.touch(@dirname)
        dir = Wright::Resource::Directory.new(@dirname)
        proc { dir.create! }.must_raise Errno::EEXIST
      end
    end
  end

  describe '#remove!' do
    it 'should remove directories' do
      FakeFS do
        FileUtils.mkdir_p(@dirname)
        dir = Wright::Resource::Directory.new(@dirname)
        dir.remove!
        assert !File.exist?(@dirname)
      end
    end

    it 'should not remove non-empty directories' do
      FakeFS do
        FileUtils.mkdir_p(@dirname)
        FileUtils.touch(File.join(@dirname, 'somefile'))
        dir = Wright::Resource::Directory.new(@dirname)
        proc { dir.remove! }.must_raise Errno::ENOTEMPTY
        assert File.directory?(@dirname)
      end
    end
  end
end
