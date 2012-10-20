require_relative '../spec_helper'

require 'wright/util/file'

include Wright

describe Util::File do
  before(:each) do
    @file = 'somefile'
    @dir = 'somedir'
  end

  describe 'file_mode_to_i' do
    it 'should not change octal integer modes' do
      Util::File.file_mode_to_i(0644, 'nonexistent').must_equal 0644
    end

    it 'should convert numeric string modes' do
      Util::File.file_mode_to_i('0644', 'nonexistent').must_equal 0644
      Util::File.file_mode_to_i( '644', 'nonexistent').must_equal 0644
    end

    it 'should convert symbolic modes' do
      FakeFS do
        FileUtils.touch(@file)
        FileUtils.chmod(00644, @file)
        Util::File.file_mode_to_i('u=rw,go=r', @file).must_equal 0644
        Util::File.file_mode_to_i('u=r,go+w', @file).must_equal 0466
        Util::File.file_mode_to_i('+x' , @file).must_equal  0755
        Util::File.file_mode_to_i('+X' , @file).must_equal  0644
        Util::File.file_mode_to_i('a-r', @file).must_equal  0200
        Util::File.file_mode_to_i('+s' , @file).must_equal 06644
        Util::File.file_mode_to_i('+t' , @file).must_equal 01644
        FakeFS::FileSystem.clear
      end
    end

    it 'should respect the current umask for relative modes' do
      old_umask = File.umask
      File.umask(0000)
      Util::File.file_mode_to_i('o=').must_equal 0660
      File.umask(0246)
      Util::File.file_mode_to_i('o=').must_equal 0420
      File.umask(old_umask)
    end

    it 'should raise an exception for invalid symbolic modes' do
      proc do
        Util::File.file_mode_to_i('this is not a mode string', @file)
      end.must_raise ArgumentError
    end
  end

  describe 'dir_mode_to_i' do
    it 'should not change octal integer modes' do
      Util::File.dir_mode_to_i(0644, 'nonexistent').must_equal 0644
    end

    it 'should convert numeric string modes' do
      Util::File.dir_mode_to_i('0644', 'nonexistent').must_equal 0644
      Util::File.dir_mode_to_i( '644', 'nonexistent').must_equal 0644
    end

    it 'should convert symbolic modes' do
      FakeFS do
        FileUtils.mkdir(@dir)
        FileUtils.chmod(00644, @dir)
        Util::File.dir_mode_to_i('u=rw,go=r', @dir).must_equal 0644
        Util::File.dir_mode_to_i('+x' , @dir).must_equal 0755
        Util::File.dir_mode_to_i('+X' , @dir).must_equal 0755
        FakeFS::FileSystem.clear
      end
    end

    it 'should respect the current umask for relative modes' do
      old_umask = File.umask
      File.umask(0000)
      Util::File.dir_mode_to_i('o=').must_equal 0770
      File.umask(0246)
      Util::File.dir_mode_to_i('o=').must_equal 0530
      File.umask(old_umask)
    end

    it 'should raise an exception for invalid symbolic modes' do
      proc do
        Util::File.dir_mode_to_i('this is not a mode string', @dir)
      end.must_raise ArgumentError
    end
  end
end
