require_relative '../spec_helper'

require 'wright/util/file_owner'

describe Wright::Util::FileOwner do
  before(:each) do
    @owner = Wright::Util::FileOwner.new
  end

  describe '#user_and_group=' do
    it 'should set the user' do
      @owner.group = 'group'
      @owner.user_and_group = 'user'
      @owner.user.must_equal 'user'
      @owner.group.must_equal 'group'
    end

    it 'should set the user when given a uid' do
      @owner.user_and_group = 23
      @owner.user.must_equal 23
    end

    it 'should support user:group notation' do
      @owner.user_and_group = 'user:group'
      @owner.user.must_equal 'user'
      @owner.group.must_equal 'group'
    end

    it 'should reject user:group strings with invalid notation' do
      invalid_owner = 'user:group:something:else'
      invalid_call = -> { @owner.user_and_group = invalid_owner }
      e = invalid_call.must_raise ArgumentError
      e.message.must_equal "Invalid owner: '#{invalid_owner}'"
    end
  end
end
