require_relative '../../spec_helper'

require 'fakeetc'
require 'wright/provider'
require 'wright/provider/user'
require 'wright/provider/user/darwin_directory_service'

describe Wright::Provider::User::DarwinDirectoryService do
  def dscl(command, user, key, value)
    %W(dscl . -#{command} /Users/#{user} #{key} #{value})
  end

  before(:each) do
    darwin_directory_service_dir =
      File.join(File.dirname(__FILE__), 'darwin_directory_service')
    @fake_capture3 = FakeCapture3.new(darwin_directory_service_dir, {})
    @staff_gid = 20
    @resource = OpenStruct.new(name: 'johndoe')
    FakeEtc.add_users('dummy' => { uid: 23 })
    FakeEtc.add_groups('staff' => { gid: @staff_gid },
                       'anonymous' => { gid: 123 })
  end

  after(:each) do
    FakeEtc.clear_users
    FakeEtc.clear_groups
  end

  describe '#add_user' do
    before(:each) do
      Wright::Provider::User::DarwinDirectoryService.send(:public, :add_user)
    end

    after(:each) do
      Wright::Provider::User::DarwinDirectoryService.send(:private, :add_user)
    end

    it 'should add users' do
      provider = Wright::Provider::User::DarwinDirectoryService.new(@resource)
      user = @resource.name

      @fake_capture3.expect(dscl(:create, user, 'UniqueID', 500),
                            'dscl-new-user-uid')
      @fake_capture3.expect(dscl(:create, user, 'UserShell', '/bin/bash'),
                            'dscl-new-user-shell')
      @fake_capture3.expect(dscl(:create, user, 'RealName', ''),
                            'dscl-new-user-full-name')
      @fake_capture3.expect(dscl(:create,
                                 user,
                                 'NFSHomeDirectory',
                                 "/Users/#{user}"),
                            'dscl-new-user-home')
      @fake_capture3.expect(dscl(:create, user, 'PrimaryGroupID', @staff_gid),
                            'dscl-new-user-primary-group')
      @fake_capture3.expect(dscl(:create, user, 'Password', '*'),
                            'dscl-new-user-password')
      @fake_capture3.stub do
        FakeEtc { provider.add_user }
      end
    end

    it 'should add system users' do
      user = @resource.name
      resource = OpenStruct.new(name: user, system: true)
      provider = Wright::Provider::User::DarwinDirectoryService.new(resource)

      @fake_capture3.expect(dscl(:create, user, 'UniqueID', 1),
                            'dscl-new-user-uid')
      @fake_capture3.expect(dscl(:create, user, 'UserShell', '/bin/bash'),
                            'dscl-new-user-shell')
      @fake_capture3.expect(dscl(:create, user, 'RealName', ''),
                            'dscl-new-user-full-name')
      @fake_capture3.expect(dscl(:create,
                                 user,
                                 'NFSHomeDirectory',
                                 "/Users/#{user}"),
                            'dscl-new-user-home')
      @fake_capture3.expect(dscl(:create, user, 'PrimaryGroupID', @staff_gid),
                            'dscl-new-user-primary-group')
      @fake_capture3.expect(dscl(:create, user, 'Password', '*'),
                            'dscl-new-user-password')
      @fake_capture3.stub do
        FakeEtc { provider.add_user }
      end
    end

    it 'should add users with options' do
      user = @resource.name
      resource = OpenStruct.new(name: user,
                                uid: 42,
                                primary_group: 'anonymous',
                                full_name: 'John Doe',
                                groups: [],
                                shell: '/bin/zsh',
                                home: "/home/#{user}",
                                system: true)
      provider = Wright::Provider::User::DarwinDirectoryService.new(resource)

      @fake_capture3.expect(dscl(:create, user, 'UniqueID', 42),
                            'dscl-new-user-uid')
      @fake_capture3.expect(dscl(:create, user, 'UserShell', '/bin/zsh'),
                            'dscl-new-user-shell')
      @fake_capture3.expect(dscl(:create, user, 'RealName', 'John Doe'),
                            'dscl-new-user-full-name')
      @fake_capture3.expect(dscl(:create,
                                 user,
                                 'NFSHomeDirectory',
                                 "/home/#{user}"),
                            'dscl-new-user-home')
      @fake_capture3.expect(dscl(:create, user, 'PrimaryGroupID', 123),
                            'dscl-new-user-primary-group')
      @fake_capture3.expect(dscl(:create, user, 'Password', '*'),
                            'dscl-new-user-password')
      @fake_capture3.stub do
        FakeEtc { provider.add_user }
      end
    end
  end

  describe '#update_user' do
    before(:each) do
      Wright::Provider::User::DarwinDirectoryService.send(:public,
                                                          :update_user)
    end

    after(:each) do
      Wright::Provider::User::DarwinDirectoryService.send(:private,
                                                          :update_user)
    end

    it 'should update users' do
      user = @resource.name
      @resource.uid = 42
      provider = Wright::Provider::User::DarwinDirectoryService.new(@resource)

      FakeEtc.add_users(@resource.name => { uid: @resource.uid + 1 })
      @fake_capture3.expect(dscl(:create, user, 'UniqueID', @resource.uid),
                            'dscl-new-user-uid')
      @fake_capture3.stub do
        FakeEtc { provider.update_user }
      end
    end
  end

  describe '#delete_user' do
    before(:each) do
      Wright::Provider::User::DarwinDirectoryService.send(:public,
                                                          :delete_user)
    end

    after(:each) do
      Wright::Provider::User::DarwinDirectoryService.send(:private,
                                                          :delete_user)
    end

    it 'should delete users' do
      provider = Wright::Provider::User::DarwinDirectoryService.new(@resource)

      FakeEtc.add_users(@resource.name => {})
      @fake_capture3.expect(%W(dscl . -delete /Users/#{@resource.name}),
                            'dscl-delete-user')
      @fake_capture3.stub do
        FakeEtc { provider.delete_user }
      end
    end
  end
end
