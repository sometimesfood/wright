require_relative '../spec_helper'

require 'wright/resource/file'
require 'wright/provider/file'
require 'fileutils'

describe Wright::Resource::File do
  before(:each) do
    @filename = 'foo'
    FakeFS { FileUtils.mkdir_p Dir.tmpdir }
  end

  after(:each) { FakeFS::FileSystem.clear }

  describe '#initialize' do
    it 'should accept attributes via an argument hash' do
      resource = Wright::Resource::File.new(@filename,
                                            content: 'sample_content',
                                            mode: 'sample_mode',
                                            action: 'sample_action',
                                            owner: 'sample_owner',
                                            group: 'sample_group')
      resource.name.must_equal @filename
      resource.content.must_equal 'sample_content'
      resource.mode.must_equal 'sample_mode'
      resource.action.must_equal 'sample_action'
      resource.owner.must_equal 'sample_owner'
      resource.group.must_equal 'sample_group'
    end
  end

  describe '#create' do
    it 'should create files' do
      FakeFS do
        file = Wright::Resource::File.new(@filename)
        file.content = 'hello world'
        file.create
        assert File.file?(@filename)
        File.read(@filename).must_equal 'hello world'
      end
    end

    it 'should create empty files when content is not set' do
      FakeFS do
        file = Wright::Resource::File.new(@filename)
        file.create
        assert File.file?(@filename)
        File.read(@filename).must_equal ''
      end
    end

    it 'should create files with the correct owner, group and mode' do
      FakeFS do
        file = Wright::Resource::File.new(@filename)
        file.content = 'hello world'
        file.owner = 23
        file.group = 42
        file.mode = '700'
        file.create
        assert File.file?(@filename)
        File.read(@filename).must_equal 'hello world'
        Wright::Util::File.file_owner(@filename).must_equal 23
        Wright::Util::File.file_group(@filename).must_equal 42
      end
    end

    it 'should update existing files' do
      FakeFS do
        FileUtils.touch(@filename)
        FileUtils.chmod(0600, @filename)
        FileUtils.chown(0, 0, @filename)
        file = Wright::Resource::File.new(@filename)
        file.mode = '644'
        file.owner = 23
        file.group = 42
        file.content = 'hello world'
        file.create
        File.read(@filename).must_equal 'hello world'
        Wright::Util::File.file_mode(@filename).must_equal 0644
        Wright::Util::File.file_owner(@filename).must_equal 23
        Wright::Util::File.file_group(@filename).must_equal 42
      end
    end

    it 'should not overwrite existing files when content is nil' do
      FakeFS do
        File.write(@filename, 'old content')
        File.chmod(0600, @filename)
        file = Wright::Resource::File.new(@filename)
        file.mode = '644'
        file.create
        File.read(@filename).must_equal 'old content'
        Wright::Util::File.file_mode(@filename).must_equal 0644
      end
    end

    it 'should not change up-to-date files' do
      FakeFS do
        File.write(@filename, 'hello world')
        FileUtils.chmod(0600, @filename)
        FileUtils.chown(23, 42, @filename)
        file = Wright::Resource::File.new(@filename)
        file.mode = '600'
        file.owner = 23
        file.group = 42
        file.content = 'hello world'
        file.create
        File.read(@filename).must_equal 'hello world'
        Wright::Util::File.file_mode(@filename).must_equal 0600
        Wright::Util::File.file_owner(@filename).must_equal 23
        Wright::Util::File.file_group(@filename).must_equal 42
      end
    end

    it 'should throw an exception when the target is a directory' do
      FakeFS do
        FileUtils.mkdir_p(@filename)
        file = Wright::Resource::File.new(@filename)
        -> { file.create }.must_raise Errno::EISDIR
        assert File.directory?(@filename)
      end
    end

    it 'should raise an exception when creating files with invalid owners' do
      file = Wright::Resource::File.new(@filename)
      user = 'this_user_doesnt_exist'
      group = 'this_group_doesnt_exist'

      FakeFS do
        lambda do
          file.owner = user
          file.create
        end.must_raise ArgumentError
        File.exist?(@filename).must_equal false

        file.owner = nil
        lambda do
          file.group = group
          file.create
        end.must_raise ArgumentError
        File.exist?(@filename).must_equal false

        file.group = nil
        lambda do
          file.owner = "#{user}:#{group}"
          file.create
        end.must_raise ArgumentError
        File.exist?(@filename).must_equal false
      end
    end

    it 'should raise an exception if there is a directory at path' do
      FakeFS do
        FileUtils.mkdir(@filename)
        file = Wright::Resource::File.new(@filename)
        -> { file.create }.must_raise Errno::EISDIR
      end
    end

    it 'should expand paths' do
      FakeFS do
        filename = '~/foobar'
        expanded_path = File.expand_path(filename)
        file = Wright::Resource::File.new(filename)
        FileUtils.mkdir_p(File.expand_path('~'))
        file.mode = '0765'
        file.create
        File.exist?(expanded_path).must_equal true
        Wright::Util::File.file_mode(expanded_path).must_equal 0765
      end
    end
  end

  describe '#remove' do
    it 'should remove files' do
      FakeFS do
        FileUtils.touch(@filename)
        file = Wright::Resource::File.new(@filename)
        file.remove
        assert !File.exist?(@filename)
      end
    end

    it 'should not remove directories' do
      FakeFS do
        FileUtils.mkdir_p(@filename)
        file = Wright::Resource::File.new(@filename)
        -> { file.remove }.must_raise Errno::EISDIR
        assert File.directory?(@filename)
      end
    end

    it 'should remove symlinks' do
      FakeFS do
        FileUtils.touch('target_file')
        FileUtils.ln_s('target_file', @filename)
        file = Wright::Resource::File.new(@filename)
        assert File.symlink?(@filename)
        file.remove
        assert !File.symlink?(@filename)
        assert File.exist?('target_file')
      end
    end

    it 'should expand paths' do
      FakeFS do
        filename = '~/foobar'
        file = Wright::Resource::File.new(filename)
        FileUtils.mkdir_p(File.expand_path('~'))
        FileUtils.touch(File.expand_path(filename))
        file.remove
        File.exist?(File.expand_path(filename)).must_equal false
      end
    end
  end

  describe '#owner=' do
    it 'should support owner:group notation' do
      file = Wright::Resource::File.new(@filename)
      file.owner = 'foo:bar'
      file.owner.must_equal 'foo'
      file.group.must_equal 'bar'
      file.group = 'baz'
      file.group.must_equal 'baz'
    end

    it 'should reject owner:group strings with invalid notation' do
      file = Wright::Resource::File.new(@filename)
      -> { file.owner = 'foo:bar:baz' }.must_raise ArgumentError
    end
  end
end
