require_relative '../../spec_helper'

require 'fakeetc'
require 'wright/provider'
require 'wright/provider/user'
require 'wright/provider/user/useradd'

describe Wright::Provider::User::Useradd do
  before(:each) do
    username = 'johndoe'
    @resource = OpenStruct.new(name: username)
    useradd_dir = File.join(File.dirname(__FILE__), 'useradd')
    @fake_capture3 = FakeCapture3.new(useradd_dir, {})
  end

  after(:each) do
    FakeEtc.clear_users
    FakeEtc.clear_groups
  end

  describe '#create_user' do
    before(:each) do
      Wright::Provider::User::Useradd.send(:public, :create_user)
    end

    after(:each) do
      Wright::Provider::User::Useradd.send(:private, :create_user)
    end

    it 'should add users' do
      provider = Wright::Provider::User::Useradd.new(@resource)

      @fake_capture3.expect(%W(useradd #{@resource.name}))
      @fake_capture3.stub do
        FakeEtc { provider.create_user }
      end
    end

    it 'should add users with options' do
      username = @resource.name
      resource = OpenStruct.new(name: username,
                                uid: 42,
                                primary_group: 'anonymous',
                                full_name: 'John Doe',
                                groups: [],
                                shell: '/bin/bash',
                                home: "/home/#{username}",
                                system: false)
      provider = Wright::Provider::User::Useradd.new(resource)

      expected_args = %W(-u #{resource.uid}
                         -g #{resource.primary_group}
                         -c #{resource.full_name},,,
                         -G #{resource.groups.join(',')}
                         -s #{resource.shell}
                         -d #{resource.home}
                         #{resource.name})
      FakeEtc.add_groups('anonymous' => { gid: 123 })
      @fake_capture3.expect(['useradd', *expected_args], 'useradd_with_options')
      @fake_capture3.stub do
        FakeEtc { provider.create_user }
      end
    end

    it 'should raise an exception when using the system option' do
      username = @resource.name
      resource = OpenStruct.new(name: username, system: true)
      provider = Wright::Provider::User::Useradd.new(resource)
      lambda do
        provider.create_user
      end.must_raise NotImplementedError
    end
  end

  describe '#update_user' do
    before(:each) do
      Wright::Provider::User::Useradd.send(:public, :update_user)
    end

    after(:each) do
      Wright::Provider::User::Useradd.send(:private, :update_user)
    end

    it 'should update users' do
      @resource.uid = 42
      provider = Wright::Provider::User::Useradd.new(@resource)

      FakeEtc.add_users(@resource.name => { uid: @resource.uid + 1 })
      @fake_capture3.expect(%W(usermod -u #{@resource.uid} #{@resource.name}))
      @fake_capture3.stub do
        FakeEtc { provider.update_user }
      end
    end
  end

  describe '#remove_user' do
    before(:each) do
      Wright::Provider::User::Useradd.send(:public, :remove_user)
    end

    after(:each) do
      Wright::Provider::User::Useradd.send(:private, :remove_user)
    end

    it 'should delete users' do
      provider = Wright::Provider::User::Useradd.new(@resource)

      FakeEtc.add_users(@resource.name => {})
      @fake_capture3.expect(%W(userdel #{@resource.name}))
      @fake_capture3.stub do
        FakeEtc { provider.remove_user }
      end
    end
  end
end
