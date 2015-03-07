require_relative '../spec_helper'

require 'fakeetc'
require 'wright/provider'
require 'wright/provider/group'

describe Wright::Provider::User do
  before(:each) do
    @resource = OpenStruct.new(name: 'johndoe')
    Wright::Provider::User.send(:public, :uptodate?)
  end

  after(:each) do
    Wright::Provider::User.send(:private, :uptodate?)
    FakeEtc.clear_users
    FakeEtc.clear_groups
  end

  describe '#uptodate?' do
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

      FakeEtc.add_users('johndoe' => { uid: uid + 1})
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

  describe '#add_user' do
    it 'should raise an exception' do
      provider = Wright::Provider::User.new(@resource)
      lambda do
        provider.send(:add_user)
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

  describe '#delete_user' do
    it 'should raise an exception' do
      provider = Wright::Provider::User.new(@resource)
      lambda do
        provider.send(:delete_user)
      end.must_raise NotImplementedError
    end
  end
end
