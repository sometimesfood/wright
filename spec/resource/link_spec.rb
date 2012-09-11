require_relative '../spec_helper'

require 'wright/resource/link'
require 'fileutils'
require 'fakefs/safe'

describe Wright::Resource::Link do
  after(:each) do
    FakeFS::FileSystem.clear
  end

  it 'should create symlinks' do
    FakeFS do
      source = 'foo'
      target = 'bar'
      link = Wright::Resource::Link.new(target)
      link.source = source
      link.create!
      assert File.symlink?(target)
      File.readlink(target).must_equal(source)
    end
  end

  it 'should update symlinks to files' do
    FakeFS do
      source = 'foo'
      target = 'bar'
      FileUtils.ln_sf('oldsource', target)
      link = Wright::Resource::Link.new(target)
      link.source = source
      link.create!
      assert File.symlink?(target)
      File.readlink(target).must_equal(source)
    end
  end

  it 'should update symlinks to directories' do
    FakeFS do
      source = 'foo'
      target = 'bar'
      FileUtils.mkdir_p('somedir')
      FileUtils.ln_s('somedir', target)
      link = Wright::Resource::Link.new(target)
      link.source = source
      link.create!
      assert File.symlink?(target)
      File.readlink(target).must_equal(source)
    end
  end

  it 'should not overwrite existing files' do
    FakeFS do
      source = 'foo'
      target = 'bar'
      file_content = 'Hello world'
      File.open(target, 'w') { |f| f.write(file_content) } # TODO: FakeFS::File.write
      link = Wright::Resource::Link.new(target)
      link.source = source
      proc do
        reset_logger_config
        link.create!
      end.must_raise(Errno::EEXIST)
      File.read(target).must_equal(file_content)
    end
  end

  it 'should remove existing symlinks' do
    FakeFS do
      source = 'foo'
      target = 'bar'
      FileUtils.touch(source)
      FileUtils.ln_s(source, target)
      link = Wright::Resource::Link.new(target)
      assert File.exist?(source)
      assert File.exist?(target) && File.symlink?(target)
      link.remove!
      assert  File.exist?(source)
      assert !File.exist?(target)
    end
  end

  it 'should not remove existing regular files' do
    FakeFS do
      target = 'bar'
      FileUtils.touch(target)
      link = Wright::Resource::Link.new(target)
      assert File.exist?(target)
      proc do
        reset_logger_config
        link.remove!
      end.must_raise RuntimeError
      assert File.exist?(target)
    end
  end
end
