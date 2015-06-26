require_relative '../spec_helper'

require 'wright/resource/user'

describe Wright::Resource::User do
  before(:each) do
    @user = Wright::Resource::User.new('johndoe')
    @provider = Minitest::Mock.new
    @user.instance_variable_set(:@provider, @provider)
  end

  describe '#initialize' do
    it 'should accept attributes via an argument hash' do
      resource = Wright::Resource::User.new('sample_name',
                                            uid: 'sample_uid',
                                            full_name: 'sample_full_name',
                                            groups: 'sample_groups',
                                            shell: 'sample_shell',
                                            home: 'sample_home',
                                            primary_group: 'sample_pgroup',
                                            system: 'sample_system',
                                            action: 'sample_action')
      resource.name.must_equal 'sample_name'
      resource.uid.must_equal 'sample_uid'
      resource.full_name.must_equal 'sample_full_name'
      resource.groups.must_equal 'sample_groups'
      resource.shell.must_equal 'sample_shell'
      resource.home.must_equal 'sample_home'
      resource.primary_group.must_equal 'sample_pgroup'
      resource.system.must_equal 'sample_system'
      resource.action.must_equal 'sample_action'
    end

    it 'should accept aliased attributes via an argument hash' do
      resource = Wright::Resource::User.new('sample_name',
                                            login_group: 'sample_login_group',
                                            homedir: 'sample_homedir')
      resource.name.must_equal 'sample_name'
      resource.login_group.must_equal 'sample_login_group'
      resource.homedir.must_equal 'sample_homedir'
    end
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
