require_relative '../spec_helper'

require 'wright/util/user'

include Wright

describe Util::User do
  describe 'user_to_uid' do
    it 'should leave integer uids alone' do
      Util::User.user_to_uid(42).must_equal 42
    end

    it 'should convert user names to uids' do
      user = Etc.getpwent
      Util::User.user_to_uid(user.name).must_equal user.uid
    end
  end

  describe 'group_to_gid' do
    it 'should leave integer gids alone' do
      Util::User.group_to_gid(42).must_equal 42
    end

    it 'should convert group names to gids' do
      group = Etc.getgrent
      Util::User.group_to_gid(group.name).must_equal group.gid
    end
  end

  describe 'owner_to_owner_group' do
    it 'should return non-string owners unmodified' do
      Util::User.owner_to_owner_group(23).must_equal [23, nil]
    end

    it 'should convert owner strings to [owner, group] arrays' do
      Util::User.owner_to_owner_group('foo').must_equal ['foo', nil]
      Util::User.owner_to_owner_group('foo:bar').must_equal %w(foo bar)
    end

    it 'should raise exceptions for invalid owner strings' do
      lambda do
        Util::User.owner_to_owner_group('foo:bar:baz')
      end.must_raise ArgumentError
    end
  end
end
