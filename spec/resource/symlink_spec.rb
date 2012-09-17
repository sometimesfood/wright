require_relative '../spec_helper'

require 'wright/resource/symlink'
require 'fileutils'

describe Wright::Resource::Symlink do
  def link_resource(to, name)
    link = Wright::Resource::Symlink.new(name)
    link.to = to
    link
  end

  before(:each) do
    @to = 'foo'
    @name = 'bar'
  end

  after(:each) do
    FakeFS::FileSystem.clear
  end

  it 'should create symlinks' do
    FakeFS do
      link = link_resource(@to, @name)
      link.create!
      assert File.symlink?(@name)
      File.readlink(@name).must_equal(@to)
    end
  end

  it 'should update symlinks to files' do
    FakeFS do
      FileUtils.ln_sf('oldsource', @name)
      link = link_resource(@to, @name)
      link.create!
      assert File.symlink?(@name)
      File.readlink(@name).must_equal(@to)
    end
  end

  it 'should update symlinks to directories' do
    FakeFS do
      FileUtils.mkdir_p('somedir')
      FileUtils.ln_s('somedir', @name)
      link = link_resource(@to, @name)
      link.create!
      assert File.symlink?(@name)
      File.readlink(@name).must_equal(@to)
    end
  end

  it 'should not overwrite existing files' do
    FakeFS do
      file_content = 'Hello world'
      File.write(@name, file_content)
      link = link_resource(@to, @name)
      proc { link.create! }.must_raise(Errno::EEXIST)
      File.read(@name).must_equal(file_content)
    end
  end

  it 'should remove existing symlinks' do
    FakeFS do
      FileUtils.touch(@to)
      FileUtils.ln_s(@to, @name)
      link = Wright::Resource::Symlink.new(@name)
      assert File.exist?(@to)
      assert File.symlink?(@name)
      link.remove!
      assert  File.exist?(@to)
      assert !File.symlink?(@name)
    end
  end

  it 'should not remove existing regular files' do
    FakeFS do
      FileUtils.touch(@name)
      link = Wright::Resource::Symlink.new(@name)
      assert File.exist?(@name)
      proc { link.remove! }.must_raise RuntimeError
      assert File.exist?(@name)
    end
  end
end
