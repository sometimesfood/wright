require_relative '../spec_helper'

require 'wright/util/file_permissions'

include Wright::Util

describe FilePermissions do
  before(:each) do
    @filename = 'somefile'
    @dirname = 'somedir'
    @file_permissions = FilePermissions.new(@filename, :file)
    @dir_permissions = FilePermissions.new(@filename, :directory)
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
end
