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

  describe '#create!' do
    it 'should create symlinks' do
      # FakeFS and minitest don't get along, only use FakeFS when needed
      link = link_resource(@target, @link_name)
      proc do
        reset_logger
        FakeFS { link.create! }
      end.must_output "INFO: create symlink: #@link_name -> #@target\n"
      FakeFS do
        assert File.symlink?(@link_name)
        File.readlink(@link_name).must_equal(@target)
      end
    end

    it 'should update symlinks to files' do
      link = link_resource(@target, @link_name)
      proc do
        reset_logger
        FakeFS do
          FileUtils.ln_sf('oldtarget', @link_name)
          link.create!
        end
      end.must_output "INFO: create symlink: #@link_name -> #@target\n"
      FakeFS do
        assert File.symlink?(@link_name)
        File.readlink(@link_name).must_equal(@target)
      end
    end

    it 'should update symlinks to directories' do
      link = link_resource(@target, @link_name)
      proc do
        reset_logger
        FakeFS do
          FileUtils.mkdir_p('somedir')
          FileUtils.ln_s('somedir', @link_name)
          link.create!
        end
      end.must_output "INFO: create symlink: #@link_name -> #@target\n"
      FakeFS do
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
  end

  describe '#remove!' do
    it 'should remove existing symlinks' do
      link = Wright::Resource::Symlink.new(@link_name)
      proc do
        reset_logger
        FakeFS do
          FileUtils.touch(@target)
          FileUtils.ln_s(@target, @link_name)
          assert File.exist?(@target)
          assert File.symlink?(@link_name)
          link.remove!
          assert  File.exist?(@target)
          assert !File.symlink?(@link_name)
        end
      end.must_output "INFO: remove symlink: #@link_name\n"
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

  describe 'dry_run' do
    it 'should not actually create symlinks' do
      link = link_resource(@target, @link_name)
      message = "INFO: (would) create symlink: #@link_name -> #@target\n"
      Wright.dry_run do
        proc do
          reset_logger
          FakeFS { link.create! }
        end.must_output message
        FakeFS { assert !File.symlink?(@link_name) }
      end
    end

    it 'should not actually remove symlinks' do
      link = link_resource(@target, @link_name)
      message = "INFO: (would) remove symlink: #@link_name\n"
      Wright.dry_run do
        proc do
          reset_logger
          FakeFS do
            FileUtils.ln_sf(@target, @link_name)
            link.remove!
          end
        end.must_output message
      end
      FakeFS { assert File.symlink?(@link_name) }
    end
  end
end
