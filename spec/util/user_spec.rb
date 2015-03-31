require_relative '../spec_helper'

require 'wright/util/user'

include Wright

describe Util::User do
  before(:each) { Etc.setpwent }

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
end
