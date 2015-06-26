require_relative '../spec_helper'

require 'wright/resource/group'

describe Wright::Resource::Group do
  before(:each) do
    @group = Wright::Resource::Group.new('foo')
    @provider = Minitest::Mock.new
    @group.instance_variable_set(:@provider, @provider)
  end

  describe '#initialize' do
    it 'should accept attributes via an argument hash' do
      resource = Wright::Resource::Group.new('sample_name',
                                             members: 'sample_members',
                                             gid: 'sample_gid',
                                             system: 'sample_system',
                                             action: 'sample_action')
      resource.name.must_equal 'sample_name'
      resource.members.must_equal 'sample_members'
      resource.gid.must_equal 'sample_gid'
      resource.system.must_equal 'sample_system'
      resource.action.must_equal 'sample_action'
    end
  end

  describe '#create' do
    it 'should ask the provider to create the group' do
      @provider.expect(:create, nil)
      @provider.expect(:updated?, true)
      @group.create
      @provider.verify
    end
  end

  describe '#remove' do
    it 'should ask the provider to remove the group' do
      @provider.expect(:remove, nil)
      @provider.expect(:updated?, true)
      @group.remove
      @provider.verify
    end
  end
end
