require_relative '../spec_helper'

require 'wright/resource/user'

describe Wright::Resource::User do
  before(:each) do
    @user = Wright::Resource::User.new('johndoe')
    @provider = Minitest::Mock.new
    @user.instance_variable_set(:@provider, @provider)
  end

  describe '#create' do
    it 'should ask the provider to create the user' do
      @provider.expect(:create, nil)
      @provider.expect(:updated?, true)
      @user.create
      @provider.verify
    end
  end

  describe '#remove' do
    it 'should ask the provider to remove the user' do
      @provider.expect(:remove, nil)
      @provider.expect(:updated?, true)
      @user.remove
      @provider.verify
    end
  end
end
