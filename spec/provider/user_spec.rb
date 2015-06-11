require_relative '../spec_helper'

require 'fakeetc'

require 'wright/provider'
require 'wright/provider/group'

describe Wright::Provider::User do
  before(:each) do
    @resource = OpenStruct.new(name: 'johndoe')
  end

  after(:each) do
    FakeEtc.clear_users
    FakeEtc.clear_groups
  end

  describe '#uptodate?' do
    before(:each) { Wright::Provider::User.send(:public, :uptodate?) }
    after(:each) { Wright::Provider::User.send(:private, :uptodate?) }

    it 'should return the correct status' do
      provider = Wright::Provider::User.new(@resource)

      FakeEtc.add_users('johndoe' => {})
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_users
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal true
      end
    end

    it 'should return the correct status when given a specific uid' do
      uid = 52
      @resource.uid = uid
      provider = Wright::Provider::User.new(@resource)

      FakeEtc.add_users('johndoe' => { uid: uid + 1 })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_users
      FakeEtc.add_users('johndoe' => { uid: uid })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should return the correct status when given a specific group list' do
      groups = %w(group1 group2)
      @resource.groups = groups
      provider = Wright::Provider::User.new(@resource)

      FakeEtc.add_groups('group1' => { mem: [] },
                         'group2' => { mem: [] })
      FakeEtc.add_users('johndoe' => {})
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_groups
      FakeEtc.add_groups('group1' => { mem: %w(johndoe) },
                         'group2' => { mem: %w(johndoe) })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should return the correct status when given a full name' do
      full_name = 'John Doe'
      @resource.full_name = full_name
      provider = Wright::Provider::User.new(@resource)

      FakeEtc.add_users('johndoe' => { gecos: '' })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_users
      FakeEtc.add_users('johndoe' => { gecos: "#{full_name},,," })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should return the correct status when given a shell' do
      shell = '/bin/zsh'
      @resource.shell = shell
      provider = Wright::Provider::User.new(@resource)

      FakeEtc.add_users('johndoe' => { shell: '' })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_users
      FakeEtc.add_users('johndoe' => { shell: shell })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should return the correct status when given a home directory' do
      home = '/home/johndoe'
      @resource.home = home
      provider = Wright::Provider::User.new(@resource)

      FakeEtc.add_users('johndoe' => { dir: '' })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_users
      FakeEtc.add_users('johndoe' => { dir: home })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should return the correct status when given a primary group' do
      group = { name: 'anonymous', gid: 42 }
      @resource.primary_group = group[:name]
      provider = Wright::Provider::User.new(@resource)

      FakeEtc.add_groups(group[:name] => { gid: group[:gid] })
      FakeEtc.add_users('johndoe' => { gid: group[:gid] + 1 })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_users
      FakeEtc.add_users('johndoe' => { gid: group[:gid] })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should return the correct status when given a primary group gid' do
      group = { name: 'anonymous', gid: 42 }
      @resource.primary_group = group[:gid]
      provider = Wright::Provider::User.new(@resource)

      FakeEtc.add_groups(group[:name] => { gid: group[:gid] })
      FakeEtc.add_users('johndoe' => { gid: group[:gid] + 1 })
      FakeEtc do
        provider.uptodate?(:create).must_equal false
        provider.uptodate?(:remove).must_equal false
      end

      FakeEtc.clear_users
      FakeEtc.add_users('johndoe' => { gid: group[:gid] })
      FakeEtc do
        provider.uptodate?(:create).must_equal true
        provider.uptodate?(:remove).must_equal false
      end
    end

    it 'should raise exceptions for invalid actions' do
      provider = Wright::Provider::User.new(@resource)
      e = -> { provider.uptodate?(:foobarbaz) }.must_raise ArgumentError
      e.message.must_equal "invalid action 'foobarbaz'"
    end
  end

  describe '#create_user' do
    it 'should raise an exception' do
      provider = Wright::Provider::User.new(@resource)
      lambda do
        provider.send(:create_user)
      end.must_raise NotImplementedError
    end
  end

  describe '#update_user' do
    it 'should raise an exception' do
      provider = Wright::Provider::User.new(@resource)
      lambda do
        provider.send(:update_user)
      end.must_raise NotImplementedError
    end
  end

  describe '#remove_user' do
    it 'should raise an exception' do
      provider = Wright::Provider::User.new(@resource)
      lambda do
        provider.send(:remove_user)
      end.must_raise NotImplementedError
    end
  end

  describe '#create' do
    before(:each) do
      username = @resource.name
      @create_message = "INFO: create user: '#{username}'\n"
      @create_message_dry = "INFO: (would) create user: '#{username}'\n"
      @create_message_debug = "DEBUG: user already created: '#{username}'\n"
    end

    it 'should set the update status when the user is up-to-date' do
      provider = Wright::Provider::User.new(@resource)

      FakeEtc.add_users('johndoe' => {})
      FakeEtc do
        lambda do
          reset_logger
          provider.create
          provider.updated?.must_equal false
        end.must_output @create_message_debug
      end
    end

    it 'should set the update status when the user has to be created' do
      provider = Wright::Provider::User.new(@resource)
      mock_provider = Minitest::Mock.new

      mock_provider.expect(:create_user, nil)
      provider.stub :create_user, -> { mock_provider.create_user } do
        FakeEtc do
          lambda do
            reset_logger
            provider.create
            provider.updated?.must_equal true
          end.must_output @create_message
        end
      end
      mock_provider.verify
    end

    it 'should set the update status when the user has to be updated' do
      @resource.shell = '/bin/csh'
      provider = Wright::Provider::User.new(@resource)
      mock_provider = Minitest::Mock.new

      mock_provider.expect(:update_user, nil)
      provider.stub :update_user, -> { mock_provider.update_user } do
        FakeEtc.add_users('johndoe' => { shell: '/bin/bash' })
        FakeEtc do
          lambda do
            reset_logger
            provider.create
            provider.updated?.must_equal true
          end.must_output @create_message
        end
      end
      mock_provider.verify
    end

    it 'should set the update status in dry-run mode' do
      provider = Wright::Provider::User.new(@resource)

      Wright.dry_run do
        FakeEtc do
          lambda do
            reset_logger
            provider.create
            provider.updated?.must_equal true
          end.must_output @create_message_dry
        end
      end
    end
  end

  describe '#remove' do
    before(:each) do
      username = @resource.name
      @remove_message = "INFO: remove user: '#{username}'\n"
      @remove_message_dry = "INFO: (would) remove user: '#{username}'\n"
      @remove_message_debug = "DEBUG: user already removed: '#{username}'\n"
    end

    it 'should set the update status when the user is already removed' do
      provider = Wright::Provider::User.new(@resource)

      FakeEtc do
        lambda do
          reset_logger
          provider.remove
          provider.updated?.must_equal false
        end.must_output @remove_message_debug
      end
    end

    it 'should set the update status when the user has to be removed' do
      provider = Wright::Provider::User.new(@resource)
      mock_provider = Minitest::Mock.new

      mock_provider.expect(:remove_user, nil)
      provider.stub :remove_user, -> { mock_provider.remove_user } do
        FakeEtc.add_users(@resource.name => {})
        FakeEtc do
          lambda do
            reset_logger
            provider.remove
            provider.updated?.must_equal true
          end.must_output @remove_message
        end
      end
      mock_provider.verify
    end

    it 'should set the update status in dry-run mode' do
      provider = Wright::Provider::User.new(@resource)

      Wright.dry_run do
        FakeEtc.add_users(@resource.name => {})
        FakeEtc do
          lambda do
            reset_logger
            provider.remove
            provider.updated?.must_equal true
          end.must_output @remove_message_dry
        end
      end
    end
  end
end
