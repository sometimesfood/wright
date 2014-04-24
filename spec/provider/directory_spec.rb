require_relative '../spec_helper'

require 'wright/provider/directory'
require 'wright/dry_run'

describe Wright::Provider::Directory do
  before(:each) do
    @dir_resource = OpenStruct.new(name: '/tmp/foo',
                                   owner: 23,
                                   group: 42,
                                   mode: 0700)

    dir = "'#{@dir_resource.name}'"
    @create_message = "INFO: create directory: #{dir}\n"
    @create_message_dry = "INFO: (would) create directory: #{dir}\n"
    @create_message_debug = "DEBUG: directory already created: #{dir}\n"
    @remove_message = "INFO: remove directory: #{dir}\n"
    @remove_message_dry = "INFO: (would) remove directory: #{dir}\n"
    @remove_message_debug = "DEBUG: directory already removed: #{dir}\n"
  end

  after(:each) { FakeFS::FileSystem.clear }

  def create_target_dir
    dir = @dir_resource.name
    FileUtils.mkdir_p(dir)
    FileUtils.chmod(@dir_resource.mode, dir)
    FileUtils.chown(@dir_resource.owner, @dir_resource.group, dir)
  end

  describe '#updated?' do
    it 'should return the update status if a directory was created' do
      dir = Wright::Provider::Directory.new(@dir_resource)
      lambda do
        reset_logger
        FakeFS { dir.create }
      end.must_output @create_message
      assert dir.updated?
    end

    it 'should return the update status if a directory was not created' do
      dir = Wright::Provider::Directory.new(@dir_resource)
      lambda do
        reset_logger
        FakeFS do
          create_target_dir
          dir.create
        end
        assert !dir.updated?
      end.must_output @create_message_debug
    end

    it 'should return the update status if a directory was changed' do
      dir = Wright::Provider::Directory.new(@dir_resource)
      lambda do
        reset_logger
        FakeFS do
          create_target_dir
          FileUtils.chown(0, 0, @dir_resource.name)
          dir.create
        end
      end.must_output @create_message
      assert dir.updated?
    end

    it 'should return the update status if a directory was removed' do
      dir = Wright::Provider::Directory.new(@dir_resource)
      lambda do
        reset_logger
        FakeFS do
          create_target_dir
          dir.remove
        end
        assert dir.updated?
      end.must_output @remove_message
    end

    it 'should return the update status if a directory was not removed' do
      dir = Wright::Provider::Directory.new(@dir_resource)
      lambda do
        reset_logger
        FakeFS { dir.remove }
        assert !dir.updated?
      end.must_output @remove_message_debug
    end
  end

  describe 'dry_run' do
    it 'should not actually create directories' do
      dir = Wright::Provider::Directory.new(@dir_resource)
      Wright.dry_run do
        lambda do
          reset_logger
          FakeFS { dir.create }
        end.must_output @create_message_dry
        FakeFS { assert !File.directory?(@dir_resource.name) }
      end
    end

    it 'should not actually remove directories' do
      dir = Wright::Provider::Directory.new(@dir_resource)
      Wright.dry_run do
        lambda do
          reset_logger
          FakeFS do
            create_target_dir
            dir.remove
          end
        end.must_output @remove_message_dry
      end
      FakeFS { assert File.directory?(@dir_resource.name) }
    end
  end
end
