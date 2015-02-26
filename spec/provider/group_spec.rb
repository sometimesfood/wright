require_relative '../spec_helper'

require 'fakeetc'

require 'wright/provider'
require 'wright/provider/group'

describe Wright::Provider::Group do
  before(:each) do
    Wright::Provider::Group.send(:public, :uptodate?)
  end

  after(:each) do
    Wright::Provider::Group.send(:private, :uptodate?)
  end

  describe '#uptodate?' do
    it 'should return the correct status' do
      group_resource = OpenStruct.new(name: 'foo', gid: nil, members: nil)
      group_provider = Wright::Provider::Group.new(group_resource)

      FakeEtc.add_groups('foo' => { gid: 42, mem: [] })
      FakeEtc do
        group_provider.uptodate?(:create).must_equal true
        group_provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_groups
      FakeEtc do
        group_provider.uptodate?(:create).must_equal false
        group_provider.uptodate?(:remove).must_equal true
      end
    end

    it 'should return the correct status when given a specific gid' do
      gid = 52
      group_resource = OpenStruct.new(name: 'foo', gid: gid, members: nil)
      group_provider = Wright::Provider::Group.new(group_resource)

      FakeEtc.add_groups('foo' => { gid: 42, mem: [] })
      FakeEtc do
        group_provider.uptodate?(:create).must_equal false
        group_provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_groups
      FakeEtc.add_groups('foo' => { gid: gid, mem: [] })
      FakeEtc do
        group_provider.uptodate?(:create).must_equal true
        group_provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should return the correct status when given a specific member list' do
      members = %w(user1 user2)
      group_resource = OpenStruct.new(name: 'foo', gid: nil, members: members)
      group_provider = Wright::Provider::Group.new(group_resource)

      FakeEtc.add_groups('foo' => { gid: 42, mem: [] })
      FakeEtc do
        group_provider.uptodate?(:create).must_equal false
        group_provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_groups
      FakeEtc.add_groups('foo' => { gid: 42, mem: members })
      FakeEtc do
        group_provider.uptodate?(:create).must_equal true
        group_provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should raise exceptions for invalid actions' do
      group_resource = OpenStruct.new(name: 'foo')
      group_provider = Wright::Provider::Group.new(group_resource)
      e = -> { group_provider.uptodate?(:foobarbaz) }.must_raise ArgumentError
      e.message.must_equal "invalid action 'foobarbaz'"
    end
  end

  describe '#add_member' do
    it 'should raise an exception' do
      group_resource = OpenStruct.new(name: 'foo')
      group_provider = Wright::Provider::Group.new(group_resource)
      lambda do
        group_provider.send(:add_member, 'member', 'group')
      end.must_raise NotImplementedError
    end
  end

  describe '#remove_member' do
    it 'should raise an exception' do
      group_resource = OpenStruct.new(name: 'foo')
      group_provider = Wright::Provider::Group.new(group_resource)
      lambda do
        group_provider.send(:remove_member, 'member', 'group')
      end.must_raise NotImplementedError
    end
  end

  describe '#set_members' do
    it 'should do something' do
      group_name = 'foo'
      current_members = %w(user1 user2 user3)
      target_members = %w(user3 user4 user5)
      group_resource = OpenStruct.new(name: group_name,
                                      members: target_members)
      group_provider = Wright::Provider::Group.new(group_resource)
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
        group_provider.stub(:add_member, add_member_stub) do
          group_provider.stub(:remove_member, remove_member_stub) do
            group_provider.set_members
          end
        end
      end
      mock_provider.verify
      Wright::Provider::Group.send(:private, :set_members)
    end
  end
end
