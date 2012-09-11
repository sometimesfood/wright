require_relative '../spec_helper'

require 'wright/resource/link'
require 'fileutils'
require 'fakefs/safe'

describe Wright::Resource::Link do
  def link_resource(source, target)
    link = Wright::Resource::Link.new(target)
    link.source = source
    link
  end

  before(:each) do
    @source = 'foo'
    @target = 'bar'
  end

  after(:each) do
    FakeFS::FileSystem.clear
  end

  it 'should create symlinks' do
    FakeFS do
      link = link_resource(@source, @target)
      link.create!
      assert File.symlink?(@target)
      File.readlink(@target).must_equal(@source)
    end
  end

  it 'should update symlinks to files' do
    FakeFS do
      FileUtils.ln_sf('oldsource', @target)
      link = link_resource(@source, @target)
      link.create!
      assert File.symlink?(@target)
      File.readlink(@target).must_equal(@source)
    end
  end

  it 'should update symlinks to directories' do
    FakeFS do
      FileUtils.mkdir_p('somedir')
      FileUtils.ln_s('somedir', @target)
      link = link_resource(@source, @target)
      link.create!
      assert File.symlink?(@target)
      File.readlink(@target).must_equal(@source)
    end
  end

  it 'should not overwrite existing files' do
    FakeFS do
      file_content = 'Hello world'
      File.open(@target, 'w') { |f| f.write(file_content) } # TODO: FakeFS::File.write
      link = link_resource(@source, @target)
      proc { link.create! }.must_raise(Errno::EEXIST)
      File.read(@target).must_equal(file_content)
    end
  end

  it 'should remove existing symlinks' do
    FakeFS do
      FileUtils.touch(@source)
      FileUtils.ln_s(@source, @target)
      link = Wright::Resource::Link.new(@target)
      assert File.exist?(@source)
      assert File.exist?(@target) && File.symlink?(@target)
      link.remove!
      assert  File.exist?(@source)
      assert !File.exist?(@target)
    end
  end

  it 'should not remove existing regular files' do
    FakeFS do
      FileUtils.touch(@target)
      link = Wright::Resource::Link.new(@target)
      assert File.exist?(@target)
      proc { link.remove! }.must_raise RuntimeError
      assert File.exist?(@target)
    end
  end
end
