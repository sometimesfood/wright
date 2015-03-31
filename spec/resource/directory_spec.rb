require_relative '../spec_helper'

require 'wright/resource/directory'
require 'wright/provider/directory'
require 'fileutils'

describe Wright::Resource::Directory do
  before(:each) { @dirname = 'foo' }

  after(:each) { FakeFS::FileSystem.clear }

  describe '#create' do
    it 'should create directories' do
      FakeFS do
        dir = Wright::Resource::Directory.new(@dirname)
        dir.create
        assert File.directory?(@dirname)
        Wright::Util::File.file_mode(@dirname).must_equal ~::File.umask & 0777
        Wright::Util::File.file_owner(@dirname).must_equal Process.uid
        Wright::Util::File.file_group(@dirname).must_equal Process.gid
      end
    end

    it 'should create directories with the given permissions' do
      FakeFS do
        dir = Wright::Resource::Directory.new(@dirname)
        dir.mode = '644'
        dir.owner = 23
        dir.group = 42
        dir.create
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
        dir.create
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
        dir.create
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
        dir.create
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
        Wright::Resource::Directory.new(@dirname).create
        Wright::Util::File.file_mode(@dirname).must_equal(mode)
        Wright::Util::File.file_owner(@dirname).must_equal(owner)
        Wright::Util::File.file_group(@dirname).must_equal(group)
      end
    end

    it 'should raise an exception when creating dirs with invalid owners' do
      dir = Wright::Resource::Directory.new(@dirname)
      user = 'this_user_doesnt_exist'
      group = 'this_group_doesnt_exist'

      FakeFS do
        lambda do
          dir.owner = user
          dir.create
        end.must_raise ArgumentError
        Dir.exist?(@dirname).must_equal false

        lambda do
          dir.group = group
          dir.create
        end.must_raise ArgumentError
        Dir.exist?(@dirname).must_equal false

        lambda do
          dir.owner = "#{user}:#{group}"
          dir.create
        end.must_raise ArgumentError
        Dir.exist?(@dirname).must_equal false
      end
    end

    it 'should raise an exception if there is a regular file at path' do
      FakeFS do
        FileUtils.touch(@dirname)
        dir = Wright::Resource::Directory.new(@dirname)
        -> { dir.create }.must_raise Errno::EEXIST
      end
    end

    it 'should expand paths' do
      FakeFS do
        dirname = '~/foobar'
        dir = Wright::Resource::Directory.new(dirname)
        FileUtils.mkdir_p(File.expand_path('~'))
        dir.create
        Dir.exist?(File.expand_path(dirname)).must_equal true
      end
    end
  end

  describe '#remove' do
    it 'should remove directories' do
      FakeFS do
        FileUtils.mkdir_p(@dirname)
        dir = Wright::Resource::Directory.new(@dirname)
        dir.remove
        assert !File.exist?(@dirname)
      end
    end

    it 'should not remove non-empty directories' do
      FakeFS do
        FileUtils.mkdir_p(@dirname)
        FileUtils.touch(File.join(@dirname, 'somefile'))
        dir = Wright::Resource::Directory.new(@dirname)
        -> { dir.remove }.must_raise Errno::ENOTEMPTY
        assert File.directory?(@dirname)
      end
    end

    it 'should not remove regular files' do
      FakeFS do
        FileUtils.touch(@dirname)
        dir = Wright::Resource::Directory.new(@dirname)
        -> { dir.remove }.must_raise RuntimeError
        assert File.exist?(@dirname)
      end
    end

    it 'should expand paths' do
      FakeFS do
        dirname = '~/foobar'
        dir = Wright::Resource::Directory.new(dirname)
        FileUtils.mkdir_p(File.expand_path(dirname))
        dir.remove
        Dir.exist?(File.expand_path(dirname)).must_equal false
      end
    end
  end

  describe '#owner=' do
    it 'should support owner:group notation' do
      dir = Wright::Resource::Directory.new(@dirname)
      dir.owner = 'foo:bar'
      dir.owner.must_equal 'foo'
      dir.group.must_equal 'bar'
      dir.group = 'baz'
      dir.group.must_equal 'baz'
    end

    it 'should reject owner:group strings with invalid notation' do
      dir = Wright::Resource::Directory.new(@dirname)
      -> { dir.owner = 'foo:bar:baz' }.must_raise ArgumentError
    end
  end
end
