require_relative '../spec_helper'

require 'wright/util/file'

include Wright

describe Util::File do
  before(:each) do
    @file = 'somefile'
    @dir = 'somedir'
    Etc.setpwent
  end

  after(:each) { FakeFS::FileSystem.clear }

  describe 'file_mode' do
    it 'should return the correct mode for a given file' do
      FakeFS do
        FileUtils.touch(@file)
        FileUtils.chmod(0644, @file)
        Util::File.file_mode(@file).must_equal 0644
      end
    end

    it 'should return nil for non-existing files' do
      FakeFS { Util::File.file_mode(@file).must_be_nil }
    end
  end

  describe 'file_owner' do
    it 'should return the correct owner for a given file' do
      FakeFS do
        FileUtils.touch(@file)
        pwent = Etc.getpwent
        File.chown(pwent.uid, pwent.gid, @file)
        Util::File.file_owner(@file).must_equal pwent.uid
      end
    end

    it 'should return nil for non-existing files' do
      FakeFS { Util::File.file_mode(@file).must_be_nil }
    end
  end

  describe 'file_group' do
    it 'should return the correct group for a given file' do
      FakeFS do
        FileUtils.touch(@file)
        pwent = Etc.getpwent
        File.chown(pwent.uid, pwent.gid, @file)
        Util::File.file_group(@file).must_equal pwent.gid
      end
    end

    it 'should return nil for non-existing files' do
      FakeFS { Util::File.file_group(@file).must_be_nil }
    end
  end

  describe 'numeric_mode_to_i' do
    it 'should not change octal integer modes' do
      Util::File.numeric_mode_to_i(0644).must_equal 0644
    end

    it 'should convert numeric string modes' do
      Util::File.numeric_mode_to_i('0644').must_equal 0644
      Util::File.numeric_mode_to_i('644').must_equal 0644
    end

    it 'should return nil for non-numeric mode strings' do
      Util::File.numeric_mode_to_i('banana').must_equal nil
    end
  end

  describe 'symbolic_mode_to_i' do
    it 'should convert symbolic modes for files' do
      type = :file
      mode = 00644
      FakeFS do
        FileUtils.touch(@file)
        FileUtils.chmod(mode, @file)
        Util::File.symbolic_mode_to_i('u=rw,go=r', mode, type).must_equal 0644
        Util::File.symbolic_mode_to_i('u=r,go+w', mode, type).must_equal 0466
        Util::File.symbolic_mode_to_i('+x', mode, type).must_equal 0755
        Util::File.symbolic_mode_to_i('+X', mode, type).must_equal 0644
        Util::File.symbolic_mode_to_i('a-r', mode, type).must_equal 0200
        Util::File.symbolic_mode_to_i('+s', mode, type).must_equal 06644
        Util::File.symbolic_mode_to_i('+t', mode, type).must_equal 01644
      end
    end

    it 'should convert symbolic modes for directories' do
      type = :directory
      mode = 00644
      FakeFS do
        FileUtils.mkdir(@dir)
        FileUtils.chmod(mode, @dir)
        Util::File.symbolic_mode_to_i('u=rw,go=r', mode, type).must_equal 0644
        Util::File.symbolic_mode_to_i('+x', mode, type).must_equal 0755
        Util::File.symbolic_mode_to_i('+X', mode, type).must_equal 0755
      end
    end

    it 'should raise an exception for invalid symbolic modes' do
      lambda do
        Util::File.symbolic_mode_to_i('this is not a mode string', nil, :file)
      end.must_raise ArgumentError
    end
  end

  describe 'expand_tilde_path' do
    it 'should expand tilde paths' do
      expected = File.join(Etc.getpwnam('root').dir, 'foo')
      actual = Wright::Util::File.expand_tilde_path('~root/foo')
      actual.must_equal expected
    end

    it 'should not expand anything but the first path element' do
      expected = File.join(Etc.getpwnam('root').dir, 'foo', '..')
      actual = Wright::Util::File.expand_tilde_path('~root/foo/..')
      actual.must_equal expected
    end

    it 'should not expand non-tilde paths' do
      Wright::Util::File.expand_tilde_path('../foo/bar').must_equal '../foo/bar'
    end
  end
end
