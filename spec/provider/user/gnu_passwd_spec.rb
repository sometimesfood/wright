require_relative '../../spec_helper'

require 'wright/provider/user/gnu_passwd'

describe Wright::Provider::User::GnuPasswd do
  describe '#system_user_option' do
    it 'should return -r' do
      resource = OpenStruct.new(name: 'foo')
      user = Wright::Provider::User::GnuPasswd.new(resource)
      expected = '-r'
      actual = user.send(:system_user_option)
      actual.must_equal expected
    end
  end
end
