require_relative '../../spec_helper'

require 'wright/provider/user/gnu'

describe Wright::Provider::User::Gnu do
  describe '#system_user_option' do
    it 'should return -r' do
      resource = OpenStruct.new(name: 'foo')
      user = Wright::Provider::User::Gnu.new(resource)
      expected = '-r'
      actual = user.send(:system_user_option)
      actual.must_equal expected
    end
  end
end
