require_relative '../spec_helper'

require 'wright/provider/file'
require 'wright/dry_run'

describe Wright::Provider::File do
  before(:each) do
    @file_resource = OpenStruct.new(name: 'foo',
                                    owner: 23,
                                    group: 42,
                                    mode: 0600,
                                    content: 'Hello world')

    file = "'#{@file_resource.name}'"
    @create_message = "INFO: create file: #{file}\n"
    @create_message_dry = "INFO: (would) create file: #{file}\n"
    @create_message_debug = "DEBUG: file already created: #{file}\n"
    @remove_message = "INFO: remove file: #{file}\n"
    @remove_message_dry = "INFO: (would) remove file: #{file}\n"
    @remove_message_debug = "DEBUG: file already removed: #{file}\n"

    FakeFS { FileUtils.mkdir_p Dir.tmpdir }
  end

  after(:each) { FakeFS::FileSystem.clear }

  def create_target_file
    file = @file_resource.name
    File.write(file, @file_resource.content)
    FileUtils.chmod(@file_resource.mode, file)
    FileUtils.chown(@file_resource.owner, @file_resource.group, file)
  end

  describe '#updated?' do
    it 'should return the update status if a file was created' do
      file = Wright::Provider::File.new(@file_resource)
      lambda do
        reset_logger
        FakeFS { file.create }
      end.must_output @create_message
      assert file.updated?
    end

    it 'should return the update status if a file was not created' do
      file = Wright::Provider::File.new(@file_resource)
      lambda do
        reset_logger
        FakeFS do
          create_target_file
          file.create
        end
        assert !file.updated?
      end.must_output @create_message_debug
    end

    it 'should return the update status if permissions were changed' do
      file = Wright::Provider::File.new(@file_resource)
      lambda do
        reset_logger
        FakeFS do
          create_target_file
          File.chmod(0111, @file_resource.name)
          file.create
        end
        assert file.updated?
      end.must_output @create_message
    end

    it 'should return the update status if a file was changed' do
      file = Wright::Provider::File.new(@file_resource)
      lambda do
        reset_logger
        FakeFS do
          create_target_file
          File.write(@file_resource.name, 'wrong content')
          file.create
        end
      end.must_output @create_message
      assert file.updated?
    end

    it 'should return the update status if a file was removed' do
      file = Wright::Provider::File.new(@file_resource)
      lambda do
        reset_logger
        FakeFS do
          create_target_file
          file.remove
        end
        assert file.updated?
      end.must_output @remove_message
    end

    it 'should return the update status if a file was not removed' do
      file = Wright::Provider::File.new(@file_resource)
      lambda do
        reset_logger
        FakeFS { file.remove }
        assert !file.updated?
      end.must_output @remove_message_debug
    end
  end

  describe 'dry_run' do
    it 'should not actually create files' do
      file = Wright::Provider::File.new(@file_resource)
      Wright.dry_run do
        lambda do
          reset_logger
          FakeFS { file.create }
        end.must_output @create_message_dry
        FakeFS { assert !File.exist?(@file_resource.name) }
      end
    end

    it 'should not actually remove files' do
      file = Wright::Provider::File.new(@file_resource)
      Wright.dry_run do
        lambda do
          reset_logger
          FakeFS do
            create_target_file
            file.remove
          end
        end.must_output @remove_message_dry
      end
      FakeFS { assert File.exist?(@file_resource.name) }
    end
  end
end
