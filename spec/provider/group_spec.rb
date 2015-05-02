require_relative '../spec_helper'

require 'fakeetc'

require 'wright/provider'
require 'wright/provider/group'

describe Wright::Provider::Group do
  before(:each) { @resource = OpenStruct.new(name: 'foo') }
  after(:each) { FakeEtc.clear_groups }

  describe '#uptodate?' do
    before(:each) do
      Wright::Provider::Group.send(:public, :uptodate?)
    end

    after(:each) do
      Wright::Provider::Group.send(:private, :uptodate?)
    end

    it 'should return the correct status' do
      provider = Wright::Provider::Group.new(@resource)

      FakeEtc.add_groups('foo' => { gid: 42, mem: %w(user1 user2) })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_groups
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal true
      end
    end

    it 'should return the correct status when given a specific gid' do
      @resource.gid = 52
      provider = Wright::Provider::Group.new(@resource)

      FakeEtc.add_groups('foo' => { gid: 42, mem: [] })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_groups
      FakeEtc.add_groups('foo' => { gid: @resource.gid, mem: [] })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should return the correct status when given a specific member list' do
      @resource.members = %w(user1 user2)
      provider = Wright::Provider::Group.new(@resource)

      FakeEtc.add_groups('foo' => { gid: 42, mem: [] })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_groups
      FakeEtc.add_groups('foo' => { gid: 42, mem: @resource.members })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should raise exceptions for invalid actions' do
      provider = Wright::Provider::Group.new(@resource)
      e = -> { provider.uptodate?(:foobarbaz) }.must_raise ArgumentError
      e.message.must_equal "invalid action 'foobarbaz'"
    end
  end

  describe '#create' do
    before(:each) do
      group = @resource.name
      @create_message = "INFO: create group: '#{group}'\n"
      @create_message_dry = "INFO: (would) create group: '#{group}'\n"
      @create_message_debug = "DEBUG: group already created: '#{group}'\n"
    end

    it 'should set the update status when the group is up-to-date' do
      provider = Wright::Provider::Group.new(@resource)

      FakeEtc.add_groups('foo' => {})
      FakeEtc do
        lambda do
          reset_logger
          provider.create
          provider.updated?.must_equal false
        end.must_output @create_message_debug
      end
    end

    it 'should set the update status when the group has to be created' do
      provider = Wright::Provider::Group.new(@resource)
      mock_provider = Minitest::Mock.new

      mock_provider.expect(:create_group, nil)
      provider.stub :create_group, -> { mock_provider.create_group } do
        FakeEtc do
          lambda do
            reset_logger
            provider.create
            provider.updated?.must_equal true
          end.must_output @create_message
        end
        mock_provider.verify
      end
    end

    it 'should set the update status when the group has to be updated' do
      @resource.gid = 123
      @resource.members = %w(johndoe janedoe)
      provider = Wright::Provider::Group.new(@resource)
      mock_provider = Minitest::Mock.new

      mock_provider.expect(:set_gid, nil)
      mock_provider.expect(:set_members, nil)
      provider.stub :set_gid, -> { mock_provider.set_gid } do
        provider.stub :set_members, -> { mock_provider.set_members } do
          FakeEtc.add_groups(@resource.name => { mem: [] })
          FakeEtc do
            lambda do
              reset_logger
              provider.create
              provider.updated?.must_equal true
            end.must_output @create_message
          end
        end
      end
      mock_provider.verify
    end

    it 'should set the update status in dry-run mode' do
      provider = Wright::Provider::Group.new(@resource)

      Wright.dry_run do
        FakeEtc do
          lambda do
            reset_logger
            provider.create
            provider.updated?.must_equal true
          end.must_output @create_message_dry
        end
      end
    end
  end

  describe '#remove' do
    before(:each) do
      group = @resource.name
      @remove_message = "INFO: remove group: '#{group}'\n"
      @remove_message_dry = "INFO: (would) remove group: '#{group}'\n"
      @remove_message_debug = "DEBUG: group already removed: '#{group}'\n"
    end

    it 'should set the update status when the group is already removed' do
      provider = Wright::Provider::Group.new(@resource)

      FakeEtc do
        lambda do
          reset_logger
          provider.remove
          provider.updated?.must_equal false
        end.must_output @remove_message_debug
      end
    end

    it 'should set the update status when the group has to be removed' do
      provider = Wright::Provider::Group.new(@resource)
      mock_provider = Minitest::Mock.new

      mock_provider.expect(:remove_group, nil)
      provider.stub :remove_group, -> { mock_provider.remove_group } do
        FakeEtc.add_groups(@resource.name => {})
        FakeEtc do
          lambda do
            reset_logger
            provider.remove
            provider.updated?.must_equal true
          end.must_output @remove_message
        end
      end
      mock_provider.verify
    end

    it 'should set the update status in dry-run mode' do
      provider = Wright::Provider::Group.new(@resource)

      Wright.dry_run do
        FakeEtc.add_groups(@resource.name => {})
        FakeEtc do
          lambda do
            reset_logger
            provider.remove
            provider.updated?.must_equal true
          end.must_output @remove_message_dry
        end
      end
    end
  end

  describe '#add_member' do
    it 'should raise an exception' do
      provider = Wright::Provider::Group.new(@resource)
      lambda do
        provider.send(:add_member, 'member', 'group')
      end.must_raise NotImplementedError
    end
  end

  describe '#remove_member' do
    it 'should raise an exception' do
      provider = Wright::Provider::Group.new(@resource)
      lambda do
        provider.send(:remove_member, 'member', 'group')
      end.must_raise NotImplementedError
    end
  end

  describe '#set_members' do
    it 'should use add_member and remove_member to update the member list' do
      group_name = @resource.name
      current_members = %w(user1 user2 user3)
      target_members = %w(user3 user4 user5)
      @resource.members = target_members
      provider = Wright::Provider::Group.new(@resource)
      Wright::Provider::Group.send(:public, :set_members)

      mock_provider = Minitest::Mock.new
      add_member_stub = ->(m, g) { mock_provider.add_member(m, g) }
      remove_member_stub = ->(m, g) { mock_provider.remove_member(m, g) }

      mock_provider.expect(:add_member, true, %W(user4 #{group_name}))
      mock_provider.expect(:add_member, true, %W(user5 #{group_name}))
      mock_provider.expect(:remove_member, true, %W(user1 #{group_name}))
      mock_provider.expect(:remove_member, true, %W(user2 #{group_name}))

      FakeEtc.add_groups('foo' => { gid: 42, mem: current_members })
      FakeEtc do
        provider.stub(:add_member, add_member_stub) do
          provider.stub(:remove_member, remove_member_stub) do
            provider.set_members
          end
        end
      end
      mock_provider.verify
      Wright::Provider::Group.send(:private, :set_members)
    end
  end

  describe '#create_group' do
    it 'should raise an exception' do
      provider = Wright::Provider::Group.new(@resource)
      lambda do
        provider.send(:create_group)
      end.must_raise NotImplementedError
    end
  end

  describe '#remove_group' do
    it 'should raise an exception' do
      provider = Wright::Provider::Group.new(@resource)
      lambda do
        provider.send(:remove_group)
      end.must_raise NotImplementedError
    end
  end

  describe '#set_gid' do
    it 'should raise an exception' do
      provider = Wright::Provider::Group.new(@resource)
      lambda do
        provider.send(:set_gid)
      end.must_raise NotImplementedError
    end
  end
end
