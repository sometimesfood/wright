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
end
