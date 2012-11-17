require_relative '../spec_helper'

require 'wright/resource/directory'
require 'wright/provider/directory'
require 'fileutils'

describe Wright::Resource::Directory do
  before(:each) { @dirname = 'foo' }

  after(:each) { FakeFS::FileSystem.clear }

  describe '#create!' do
    it 'should create directories' do
      FakeFS do
        dir = Wright::Resource::Directory.new(@dirname)
        dir.mode = '644'
        dir.owner = 23
        dir.group = 42
        dir.create!
        assert File.directory?(@dirname)
        Wright::Util::File.file_mode(@dirname).must_equal 0644
        Wright::Util::File.file_owner(@dirname).must_equal 23
        Wright::Util::File.file_group(@dirname).must_equal 42
      end
    end

    it 'should create directories recursively' do
      FakeFS do
        dirname = File.join(@dirname, @dirname, @dirname)
        dir = Wright::Resource::Directory.new(dirname)
        dir.create!
        assert File.directory?(dirname)
      end
    end

    it 'should update existing directories' do
      FakeFS do
        FileUtils.mkdir_p(@dirname)
        FileUtils.chmod(0600, @dirname)
        FileUtils.chown(0, 0, @dirname)
        dir = Wright::Resource::Directory.new(@dirname)
        dir.mode = '644'
        dir.owner = 23
        dir.group = 42
        dir.create!
        assert File.directory?(@dirname)
        Wright::Util::File.file_mode(@dirname).must_equal 0644
        Wright::Util::File.file_owner(@dirname).must_equal 23
        Wright::Util::File.file_group(@dirname).must_equal 42
      end
    end

    it 'should update the access mode for existing directories' do
      FakeFS do
        FileUtils.mkdir_p(@dirname)
        FileUtils.chmod(0600, @dirname)
        dir = Wright::Resource::Directory.new(@dirname)
        dir.mode = '644'
        dir.create!
        assert File.directory?(@dirname)
        Wright::Util::File.file_mode(@dirname).must_equal 0644
      end
    end

    it 'should not change up-to-date directories' do
      FakeFS do
        FileUtils.mkdir_p(@dirname)
        mode = Wright::Util::File.file_mode(@dirname)
        owner = Wright::Util::File.file_owner(@dirname)
        group = Wright::Util::File.file_group(@dirname)
        Wright::Resource::Directory.new(@dirname).create!
        Wright::Util::File.file_mode(@dirname).must_equal(mode)
        Wright::Util::File.file_owner(@dirname).must_equal(owner)
        Wright::Util::File.file_group(@dirname).must_equal(group)
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

    it 'should not remove regular files' do
      FakeFS do
        FileUtils.touch(@dirname)
        dir = Wright::Resource::Directory.new(@dirname)
        proc { dir.remove! }.must_raise RuntimeError
        assert File.exist?(@dirname)
      end
    end
  end
end
