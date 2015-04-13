require_relative '../../spec_helper'

require 'wright/provider/group/darwin_directory_service'
require 'fakeetc'

describe Wright::Provider::Group::DarwinDirectoryService do
  def dseditgroup(command, group_name, gid = nil, system = false)
    if command != :delete
      gid ||= @groups['daemon'][:gid] + 1 if system
      options = gid.nil? ? [] : ['-i', gid.to_s]
      ['dseditgroup', '-o', command.to_s, *options, group_name]
    else
      ['dseditgroup', '-o', command.to_s, group_name]
    end
  end

  def dscl_set_members(group_name, members)
    options = ['GroupMembership', *members]
    ['dscl', '.', 'create', "/Groups/#{group_name}", *options]
  end

  def group_provider(group_name, gid = nil, members = nil, system = false)
    group_resource = OpenStruct.new(name: group_name,
                                    gid: gid,
                                    members: members,
                                    system: system)
    Wright::Provider::Group::DarwinDirectoryService.new(group_resource)
  end

  before :each do
    darwin_directory_service_dir = File.join(File.dirname(__FILE__),
                                             'darwin_directory_service')
    @fake_capture3 = FakeCapture3.new(darwin_directory_service_dir)
    @create_message = ->(group) { "INFO: create group: '#{group}'\n" }
    @create_message_dry = lambda do |group|
      "INFO: (would) create group: '#{group}'\n"
    end
    @create_message_debug = lambda do |group|
      "DEBUG: group already created: '#{group}'\n"
    end
    @remove_message = ->(group) { "INFO: remove group: '#{group}'\n" }
    @remove_message_dry = lambda do |group|
      "INFO: (would) remove group: '#{group}'\n"
    end
    @remove_message_debug = lambda do |group|
      "DEBUG: group already removed: '#{group}'\n"
    end
    @groups = { 'daemon' => { gid: 1, mem: [] },
                'foobar' => { gid: 42, mem: %w(foo bar) },
                'bazqux' => { gid: 43, mem: %w(baz qux) } }
    FakeEtc.add_groups(@groups)
  end

  describe '#create' do
    it 'should create new groups' do
      gid = 1234
      group_name = 'newgroup'
      group_provider = group_provider(group_name, gid)
      dseditgroup_cmd = dseditgroup(:create, group_name, gid)

      @fake_capture3.expect(dseditgroup_cmd)
      @fake_capture3.stub do
        FakeEtc do
          lambda do
            reset_logger
            group_provider.create
            group_provider.updated?.must_equal true
          end.must_output @create_message.call(group_name)
        end
      end
    end

    it 'should create new system groups' do
      group_name = 'newgroup'
      gid = nil
      members = nil
      system = true
      group_provider = group_provider(group_name, gid, members, system)
      dseditgroup_cmd = dseditgroup(:create, group_name, gid, system)

      @fake_capture3.expect(dseditgroup_cmd)
      @fake_capture3.stub do
        FakeEtc do
          lambda do
            reset_logger
            group_provider.create
            group_provider.updated?.must_equal true
          end.must_output @create_message.call(group_name)
        end
      end
    end

    it 'should not try to create existing groups' do
      group_name = 'foobar'
      gid = @groups[group_name][:gid]
      members = @groups[group_name][:mem]
      group_provider = group_provider(group_name, gid, members)

      @fake_capture3.stub do
        FakeEtc do
          lambda do
            reset_logger
            group_provider.create
            group_provider.updated?.must_equal false
          end.must_output @create_message_debug.call(group_name)
        end
      end
    end

    it 'should clear member lists for existing groups' do
      group_name = 'foobar'
      gid = @groups[group_name][:gid]
      members = []
      group_provider = group_provider(group_name, gid, members)
      dscl_cmd = dscl_set_members(group_name, members)

      @fake_capture3.expect(dscl_cmd)
      @fake_capture3.stub do
        FakeEtc do
          lambda do
            reset_logger
            group_provider.create
            group_provider.updated?.must_equal true
          end.must_output @create_message.call(group_name)
        end
      end
    end

    it 'should update member lists for existing groups' do
      group_name = 'foobar'
      gid = @groups[group_name][:gid]
      members = %w(user1 user2)
      group_provider = group_provider(group_name, gid, members)
      dscl_cmd = dscl_set_members(group_name, members)

      @fake_capture3.expect(dscl_cmd)
      @fake_capture3.stub do
        FakeEtc do
          lambda do
            reset_logger
            group_provider.create
            group_provider.updated?.must_equal true
          end.must_output @create_message.call(group_name)
        end
      end
    end

    it 'should update the gid for existing groups' do
      group_name = 'foobar'
      gid = @groups[group_name][:gid] + 10
      group_provider = group_provider(group_name, gid)
      dseditgroup_cmd = dseditgroup(:edit, group_name, gid)

      @fake_capture3.expect(dseditgroup_cmd)
      @fake_capture3.stub do
        FakeEtc do
          lambda do
            reset_logger
            group_provider.create
            group_provider.updated?.must_equal true
          end.must_output @create_message.call(group_name)
        end
      end
    end

    it 'should report group creation errors by dseditgroup' do
      gid = 'ERROR'
      group_name = 'newgroup'
      group_provider = group_provider(group_name, gid)
      dseditgroup_cmd = dseditgroup(:create, group_name, gid)

      @fake_capture3.expect(dseditgroup_cmd)
      @fake_capture3.stub do
        FakeEtc do
          e = -> { group_provider.create }.must_raise RuntimeError
          wright_error = "cannot create group '#{group_name}'"
          dseditgroup_error = 'GID contains non-numeric characters'
          e.message.must_equal %(#{wright_error}: "#{dseditgroup_error}")
        end
      end
    end

    it 'should report gid changing errors by dseditgroup' do
      gid = 'ERROR'
      group_name = 'foobar'
      group_provider = group_provider(group_name, gid)
      dseditgroup_cmd = dseditgroup(:edit, group_name, gid)

      @fake_capture3.expect(dseditgroup_cmd)
      @fake_capture3.stub do
        FakeEtc do
          e = -> { group_provider.create }.must_raise RuntimeError
          wright_error = "cannot create group '#{group_name}'"
          dseditgroup_error = 'GID contains non-numeric characters'
          e.message.must_equal %(#{wright_error}: "#{dseditgroup_error}")
        end
      end
    end

    it 'should report errors by dscl' do
      # simulate a "permission denied" error
      members = %w(permission-denied-user)
      group_name = 'foobar'
      group_provider = group_provider(group_name, nil, members)
      dscl_cmd = dscl_set_members(group_name, members)

      @fake_capture3.expect(dscl_cmd)
      @fake_capture3.stub do
        FakeEtc do
          e = -> { group_provider.create }.must_raise RuntimeError
          wright_error = "cannot create group '#{group_name}'"
          dscl_error = <<EOS.chomp
<main> attribute status: eDSPermissionError
<dscl_cmd> DS Error: -14120 (eDSPermissionError)
EOS
          e.message.must_equal %(#{wright_error}: "#{dscl_error}")
        end
      end
    end
  end

  describe '#remove' do
    it 'should remove existing groups' do
      group_name = 'foobar'
      group_provider = group_provider(group_name)
      dseditgroup_cmd = dseditgroup(:delete, group_name)

      @fake_capture3.expect(dseditgroup_cmd)
      @fake_capture3.stub do
        FakeEtc do
          lambda do
            reset_logger
            group_provider.remove
            group_provider.updated?.must_equal true
          end.must_output @remove_message.call(group_name)
        end
      end
    end

    it 'should not try to remove groups that are already removed' do
      group_name = 'not-a-group'
      group_provider = group_provider(group_name)

      @fake_capture3.stub do
        FakeEtc do
          lambda do
            reset_logger
            group_provider.remove
            group_provider.updated?.must_equal false
          end.must_output @remove_message_debug.call(group_name)
        end
      end
    end

    it 'should report errors by dseditgroup' do
      group_name = 'bazqux'
      group_provider = group_provider(group_name)
      dseditgroup_cmd = dseditgroup(:delete, group_name)

      @fake_capture3.expect(dseditgroup_cmd)
      @fake_capture3.stub do
        FakeEtc do
          e = -> { group_provider.remove }.must_raise RuntimeError
          wright_error = "cannot remove group '#{group_name}'"
          dseditgroup_error = 'Group not found.'
          e.message.must_equal %(#{wright_error}: "#{dseditgroup_error}")
        end
      end
    end
  end

  describe 'dry_run' do
    it 'should not actually create new groups' do
      gid = 1234
      group_name = 'newgroup'
      group_provider = group_provider(group_name, gid)

      @fake_capture3.stub do
        Wright.dry_run do
          FakeEtc do
            lambda do
              reset_logger
              group_provider.create
              group_provider.updated?.must_equal true
            end.must_output @create_message_dry.call(group_name)
          end
        end
      end
    end

    it 'should not actually update existing groups' do
      gid = 1234
      group_name = 'foobar'
      members = %w(user1 user2)
      group_provider = group_provider(group_name, gid, members)

      @fake_capture3.stub do
        Wright.dry_run do
          FakeEtc do
            lambda do
              reset_logger
              group_provider.create
              group_provider.updated?.must_equal true
            end.must_output @create_message_dry.call(group_name)
          end
        end
      end
    end

    it 'should not try to create existing groups' do
      group_name = 'foobar'
      gid = @groups[group_name][:gid]
      members = @groups[group_name][:mem]
      group_provider = group_provider(group_name, gid, members)

      @fake_capture3.stub do
        Wright.dry_run do
          FakeEtc do
            lambda do
              reset_logger
              group_provider.create
              group_provider.updated?.must_equal false
            end.must_output @create_message_debug.call(group_name)
          end
        end
      end
    end

    it 'should not actually update existing groups' do
      group_name = 'foobar'
      gid = @groups[group_name][:gid] + 10
      members = %w(user1 user2)
      group_provider = group_provider(group_name, gid, members)

      @fake_capture3.stub do
        Wright.dry_run do
          FakeEtc do
            lambda do
              reset_logger
              group_provider.create
              group_provider.updated?.must_equal true
            end.must_output @create_message_dry.call(group_name)
          end
        end
      end
    end

    it 'should not actually remove groups' do
      group_name = 'foobar'
      group_provider = group_provider(group_name)

      @fake_capture3.stub do
        Wright.dry_run do
          FakeEtc do
            lambda do
              reset_logger
              group_provider.remove
              group_provider.updated?.must_equal true
            end.must_output @remove_message_dry.call(group_name)
          end
        end
      end
    end

    it 'should not try to remove groups that are already removed' do
      group_name = 'not-a-group'
      group_provider = group_provider(group_name)

      @fake_capture3.stub do
        Wright.dry_run do
          FakeEtc do
            lambda do
              reset_logger
              group_provider.remove
              group_provider.updated?.must_equal false
            end.must_output @remove_message_debug.call(group_name)
          end
        end
      end
    end
  end
end
