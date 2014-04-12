require_relative '../spec_helper'

require 'wright/util/file_permissions'

include Wright::Util

describe FilePermissions do
  before(:each) do
    @file_permissions = FilePermissions.new('somefile', :file)
    @dir_permissions = FilePermissions.new('somedir', :directory)
  end

  after(:each) { FakeFS::FileSystem.clear }

  describe 'initialize' do
    it 'should raise exceptions for incorrect file types' do
      proc do
        FilePermissions.new(@filename, :invalid_file_type)
      end.must_raise ArgumentError
    end
  end

  describe '#default_mode' do
    it 'should return the correct default mode for files' do
      default_mode = ~::File.umask & 0666
      @file_permissions.default_mode.must_equal default_mode
    end

    it 'should return the correct default mode for directories' do
      default_mode = ~::File.umask & 0777
      @dir_permissions.default_mode.must_equal default_mode
    end
  end

  describe '#owner=' do
    it 'should raise exceptions for invalid owner strings' do
      proc do
        @file_permissions.owner = 'foo:bar:baz'
      end.must_raise ArgumentError
    end

    it 'should support integer uids' do
      @file_permissions.owner = 1234
      @file_permissions.owner.must_equal 1234
    end

    it 'should support owner:group notation' do
      @file_permissions.owner = 'owner:group'
      @file_permissions.owner.must_equal 'owner'
      @file_permissions.group.must_equal 'group'
    end
  end

  describe '#uptodate?' do
    it 'should return false for inexistent files' do
      FakeFS do
        @file_permissions.uptodate?.must_equal false
      end
    end
  end

  describe '#mode_to_i' do
    it 'should return nil if the mode has not been set' do
      FakeFS do
        @file_permissions.mode_to_i.must_be_nil

        FileUtils.touch(@file_permissions.filename)
        @file_permissions.mode_to_i.must_be_nil
      end
    end

    it 'should return the default mode for missing files' do
      @file_permissions.mode = 'ugo+'
      FakeFS do
        @file_permissions.mode_to_i.must_equal @file_permissions.default_mode
      end
    end

    it 'should return the current mode for existing files' do
      FakeFS do
        FileUtils.touch(@file_permissions.filename)
        FileUtils.chmod(0456, @file_permissions.filename)
        @file_permissions.mode = 'ugo+'
        @file_permissions.mode_to_i.must_equal 0456
      end
    end
  end

  describe '#uptodate?' do
    it 'should foo' do
      FakeFS do
        FileUtils.touch(@file_permissions.filename)
        FileUtils.chmod(0600, @file_permissions.filename)
        @file_permissions.uptodate?.must_equal true

        @file_permissions.mode = 0666
        @file_permissions.uptodate?.must_equal false

        @file_permissions.mode = 'ugo+'
        @file_permissions.uptodate?.must_equal true

        @file_permissions.mode = 'a+rwx'
        @file_permissions.uptodate?.must_equal false
      end
    end
  end

  describe '#update' do
    it 'should foo' do
      FakeFS do
        FileUtils.touch(@file_permissions.filename)

        FileUtils.chmod(0600, @file_permissions.filename)
        @file_permissions.mode = 0666
        @file_permissions.update
        @file_permissions.current_mode.must_equal 0666

        FileUtils.chmod(0600, @file_permissions.filename)
        @file_permissions.mode = 'ugo+'
        @file_permissions.update
        @file_permissions.current_mode.must_equal 0600

        FileUtils.chmod(0600, @file_permissions.filename)
        @file_permissions.mode = 'u+rwx,g=rx,o=rX'
        @file_permissions.update
        @file_permissions.current_mode.must_equal 0754
      end
    end

    it 'should foo for directories' do
      FakeFS do
        FileUtils.mkdir(@dir_permissions.filename)
        FileUtils.chmod(0600, @dir_permissions.filename)
        @dir_permissions.mode = 'u+rwx,g=rx,o=rX'
        @dir_permissions.update
        @dir_permissions.current_mode.must_equal 0755
      end
    end

    it 'should TODO owners' do
      uid_nobody = Etc.getpwnam('nobody').uid
      uid_root = Etc.getpwnam('root').uid
      FakeFS do
        FileUtils.touch(@file_permissions.filename)
        FileUtils.chown('nobody', nil, @file_permissions.filename)
        @file_permissions.current_owner.must_equal uid_nobody
        @file_permissions.owner = 'root'
        @file_permissions.uptodate?.must_equal false
        @file_permissions.update
        @file_permissions.uptodate?.must_equal true
        @file_permissions.current_owner.must_equal uid_root
      end
    end
  end
end
