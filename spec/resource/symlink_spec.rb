require_relative '../spec_helper'

require 'wright/resource/symlink'
require 'fileutils'

describe Wright::Resource::Symlink do
  def link_resource(target, link_name)
    link = Wright::Resource::Symlink.new(link_name)
    link.to = target
    link
  end

  before(:each) do
    @target = 'foo'
    @link_name = 'bar'
  end

  after(:each) do
    FakeFS::FileSystem.clear
  end

  it 'should create symlinks' do
    FakeFS do
      link = link_resource(@target, @link_name)
      link.create!
      assert File.symlink?(@link_name)
      File.readlink(@link_name).must_equal(@target)
    end
  end

  it 'should update symlinks to files' do
    FakeFS do
      FileUtils.ln_sf('oldsource', @link_name)
      link = link_resource(@target, @link_name)
      link.create!
      assert File.symlink?(@link_name)
      File.readlink(@link_name).must_equal(@target)
    end
  end

  it 'should update symlinks to directories' do
    FakeFS do
      FileUtils.mkdir_p('somedir')
      FileUtils.ln_s('somedir', @link_name)
      link = link_resource(@target, @link_name)
      link.create!
      assert File.symlink?(@link_name)
      File.readlink(@link_name).must_equal(@target)
    end
  end

  it 'should not overwrite existing files' do
    FakeFS do
      file_content = 'Hello world'
      File.write(@link_name, file_content)
      link = link_resource(@target, @link_name)
      proc { link.create! }.must_raise(Errno::EEXIST)
      File.read(@link_name).must_equal(file_content)
    end
  end

  it 'should remove existing symlinks' do
    FakeFS do
      FileUtils.touch(@target)
      FileUtils.ln_s(@target, @link_name)
      link = Wright::Resource::Symlink.new(@link_name)
      assert File.exist?(@target)
      assert File.symlink?(@link_name)
      link.remove!
      assert  File.exist?(@target)
      assert !File.symlink?(@link_name)
    end
  end

  it 'should not remove existing regular files' do
    FakeFS do
      FileUtils.touch(@link_name)
      link = Wright::Resource::Symlink.new(@link_name)
      assert File.exist?(@link_name)
      proc { link.remove! }.must_raise RuntimeError
      assert File.exist?(@link_name)
    end
  end
end
