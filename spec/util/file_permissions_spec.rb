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

  describe '#uptodate?' do
    it 'should return false for non-existent files' do
      FakeFS do
        @file_permissions.uptodate?.must_equal false
      end
    end
  end

  describe '#update' do
    it 'should update file modes when using integer modes' do
      FakeFS do
        FileUtils.touch(@file_permissions.filename)
        FileUtils.chmod(0600, @file_permissions.filename)
        @file_permissions.uptodate?.must_equal true
        @file_permissions.mode = 0666
        @file_permissions.uptodate?.must_equal false
        @file_permissions.update
        @file_permissions.current_mode.must_equal 0666
        @file_permissions.uptodate?.must_equal true
      end
    end

    it 'should not change file modes when using no-op mode strings' do
      FakeFS do
        FileUtils.touch(@file_permissions.filename)
        FileUtils.chmod(0600, @file_permissions.filename)
        @file_permissions.mode = 'ugo+'
        @file_permissions.uptodate?.must_equal true
        @file_permissions.update
        @file_permissions.current_mode.must_equal 0600
        @file_permissions.uptodate?.must_equal true
      end
    end

    it 'shouldd update file modes when using symbolic mode strings' do
      FakeFS do
        FileUtils.touch(@file_permissions.filename)
        FileUtils.chmod(0600, @file_permissions.filename)
        @file_permissions.mode = 'u+rwx,g=rx,o=rX'
        @file_permissions.uptodate?.must_equal false
        @file_permissions.update
        @file_permissions.current_mode.must_equal 0754
        @file_permissions.uptodate?.must_equal true
      end
    end

    it 'should update directory modes when using symbolic mode strings' do
      FakeFS do
        FileUtils.mkdir(@dir_permissions.filename)
        FileUtils.chmod(0600, @dir_permissions.filename)
        @dir_permissions.mode = 'u+rwx,g=rx,o=rX'
        @dir_permissions.update
        @dir_permissions.current_mode.must_equal 0755
      end
    end

    it 'should update file owners' do
      user1 = Etc.getpwent
      user2 = Etc.getpwent
      FakeFS do
        FileUtils.touch(@file_permissions.filename)
        FileUtils.chown(user1.name, nil, @file_permissions.filename)
        @file_permissions.current_owner.must_equal user1.uid
        @file_permissions.owner = user2.name
        @file_permissions.uptodate?.must_equal false
        @file_permissions.update
        @file_permissions.uptodate?.must_equal true
        @file_permissions.current_owner.must_equal user2.uid
      end
    end

    it 'should update file groups' do
      group1 = Etc.getgrent
      group2 = Etc.getgrent
      FakeFS do
        FileUtils.touch(@file_permissions.filename)
        FileUtils.chown(nil, group1.name, @file_permissions.filename)
        @file_permissions.current_group.must_equal group1.gid
        @file_permissions.group = group2.name
        @file_permissions.uptodate?.must_equal false
        @file_permissions.update
        @file_permissions.uptodate?.must_equal true
        @file_permissions.current_group.must_equal group2.gid
      end
    end
  end
end
