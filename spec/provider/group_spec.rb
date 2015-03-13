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
      resource = OpenStruct.new(name: 'foo')
      provider = Wright::Provider::Group.new(resource)

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
      gid = 52
      resource = OpenStruct.new(name: 'foo', gid: gid, members: nil)
      provider = Wright::Provider::Group.new(resource)

      FakeEtc.add_groups('foo' => { gid: 42, mem: [] })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_groups
      FakeEtc.add_groups('foo' => { gid: gid, mem: [] })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should return the correct status when given a specific member list' do
      members = %w(user1 user2)
      resource = OpenStruct.new(name: 'foo', gid: nil, members: members)
      provider = Wright::Provider::Group.new(resource)

      FakeEtc.add_groups('foo' => { gid: 42, mem: [] })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_groups
      FakeEtc.add_groups('foo' => { gid: 42, mem: members })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should raise exceptions for invalid actions' do
      resource = OpenStruct.new(name: 'foo')
      provider = Wright::Provider::Group.new(resource)
      e = -> { provider.uptodate?(:foobarbaz) }.must_raise ArgumentError
      e.message.must_equal "invalid action 'foobarbaz'"
    end
  end

  describe '#add_member' do
    it 'should raise an exception' do
      resource = OpenStruct.new(name: 'foo')
      provider = Wright::Provider::Group.new(resource)
      lambda do
        provider.send(:add_member, 'member', 'group')
      end.must_raise NotImplementedError
    end
  end

  describe '#remove_member' do
    it 'should raise an exception' do
      resource = OpenStruct.new(name: 'foo')
      provider = Wright::Provider::Group.new(resource)
      lambda do
        provider.send(:remove_member, 'member', 'group')
      end.must_raise NotImplementedError
    end
  end

  describe '#set_members' do
    it 'should use add_member and remove_member to update the member list' do
      group_name = 'foo'
      current_members = %w(user1 user2 user3)
      target_members = %w(user3 user4 user5)
      resource = OpenStruct.new(name: group_name,
                                members: target_members)
      provider = Wright::Provider::Group.new(resource)
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
end
