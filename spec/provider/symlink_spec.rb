require_relative '../spec_helper'

require 'fileutils'

require 'wright/provider/symlink'
require 'wright/dry_run'

describe Wright::Provider::Symlink do
  before(:each) do
    @link_resource = OpenStruct.new(to: 'foo', name: 'bar')

    name = @link_resource.name
    to = @link_resource.to
    symlink_to_s = "'#{name}' -> '#{to}'"
    @create_message = "INFO: create symlink: #{symlink_to_s}\n"
    @create_message_dry = "INFO: (would) create symlink: #{symlink_to_s}\n"
    @create_message_debug = "DEBUG: symlink already created: #{symlink_to_s}\n"
    @remove_message = "INFO: remove symlink: '#{name}'\n"
    @remove_message_dry = "INFO: (would) remove symlink: '#{name}'\n"
    @remove_message_debug = "DEBUG: symlink already removed: '#{name}'\n"
  end

  after(:each) do
    FakeFS::FileSystem.clear
  end

  describe '#updated?' do
    it 'should return the update status if a link was created' do
      link = Wright::Provider::Symlink.new(@link_resource)
      lambda do
        reset_logger
        FakeFS { link.create }
      end.must_output @create_message
      assert link.updated?
    end

    it 'should return the update status if a link was not created' do
      link = Wright::Provider::Symlink.new(@link_resource)
      lambda do
        FakeFS do
          reset_logger
          FileUtils.ln_sf(@link_resource.to, @link_resource.name)
          link.create
          assert !link.updated?
        end
      end.must_output @create_message_debug

      FakeFS do
        FileUtils.rm(@link_resource.name)
        FileUtils.touch(@link_resource.name)
        -> { link.create }.must_raise Errno::EEXIST
        assert !link.updated?
      end
    end

    it 'should return the update status if a link was changed' do
      link = Wright::Provider::Symlink.new(@link_resource)
      lambda do
        reset_logger
        FakeFS do
          FileUtils.ln_sf('old-source', @link_resource.name)
          link.create
        end
      end.must_output @create_message
      assert link.updated?
    end

    it 'should return the update status if a link was removed' do
      link = Wright::Provider::Symlink.new(@link_resource)
      lambda do
        reset_logger
        FakeFS do
          FileUtils.ln_sf(@link_resource.to, @link_resource.name)
          link.remove
        end
      end.must_output @remove_message
      assert link.updated?
    end

    it 'should return the update status if a link was not removed' do
      link = Wright::Provider::Symlink.new(@link_resource)
      lambda do
        reset_logger
        FakeFS { link.remove }
        assert !link.updated?
      end.must_output @remove_message_debug

      FakeFS do
        FileUtils.touch(@link_resource.name)
        -> { link.remove }.must_raise RuntimeError
        assert !link.updated?
      end
    end
  end

  describe 'dry_run' do
    it 'should not actually create symlinks' do
      link = Wright::Provider::Symlink.new(@link_resource)
      Wright.dry_run do
        lambda do
          reset_logger
          FakeFS { link.create }
        end.must_output @create_message_dry
        FakeFS { assert !File.symlink?(@link_resource.name) }
      end
    end

    it 'should not actually remove symlinks' do
      link = Wright::Provider::Symlink.new(@link_resource)
      Wright.dry_run do
        lambda do
          reset_logger
          FakeFS do
            FileUtils.ln_sf(@link_resource.to, @link_resource.name)
            link.remove
          end
        end.must_output @remove_message_dry
      end
      FakeFS { assert File.symlink?(@link_resource.name) }
    end
  end
end
