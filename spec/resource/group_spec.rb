require_relative '../spec_helper'

require 'wright/resource/group'

describe Wright::Resource::Group do
  before(:each) do
    @group = Wright::Resource::Group.new('foo')
    @provider = Minitest::Mock.new
    @group.instance_variable_set(:@provider, @provider)
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
