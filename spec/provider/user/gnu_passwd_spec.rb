require_relative '../../spec_helper'

require 'fakeetc'
require 'wright/provider'
require 'wright/provider/user'
require 'wright/provider/user/gnu_passwd'

describe Wright::Provider::User do
  before(:each) do
    username = 'johndoe'
    @resource = OpenStruct.new(name: username)
    gnu_passwd_dir = File.join(File.dirname(__FILE__), 'gnu_passwd')
    @fake_capture3 = FakeCapture3.new(gnu_passwd_dir, {})
  end

  after(:each) do
    FakeEtc.clear_users
    FakeEtc.clear_groups
  end

  describe '#add_user' do
    before(:each) do
      Wright::Provider::User::GnuPasswd.send(:public, :add_user)
    end

    after(:each) do
      Wright::Provider::User.send(:private, :add_user)
    end

    it 'should add users' do
      provider = Wright::Provider::User::GnuPasswd.new(@resource)

      @fake_capture3.expect(%W(useradd #{@resource.name}))
      @fake_capture3.stub do
        FakeEtc { provider.add_user }
      end
    end
  end

  describe '#update_user' do
    before(:each) do
      Wright::Provider::User::GnuPasswd.send(:public, :update_user)
    end

    after(:each) do
      Wright::Provider::User.send(:private, :update_user)
    end

    it 'should update users' do
      @resource.uid = 42
      provider = Wright::Provider::User::GnuPasswd.new(@resource)

      FakeEtc.add_users(@resource.name => { uid: @resource.uid + 1 })
      @fake_capture3.expect(%W(usermod -u #{@resource.uid} #{@resource.name}))
      @fake_capture3.stub do
        FakeEtc { provider.update_user }
      end
    end
  end

  describe '#update_user' do
    before(:each) do
      Wright::Provider::User::GnuPasswd.send(:public, :delete_user)
    end

    after(:each) do
      Wright::Provider::User.send(:private, :delete_user)
    end

    it 'should delete users' do
      provider = Wright::Provider::User::GnuPasswd.new(@resource)

      FakeEtc.add_users(@resource.name => {})
      @fake_capture3.expect(%W(userdel #{@resource.name}))
      @fake_capture3.stub do
        FakeEtc { provider.delete_user }
      end
    end
  end
end
