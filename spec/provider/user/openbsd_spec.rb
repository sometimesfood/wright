require_relative '../../spec_helper'

require 'wright/provider/user/openbsd'

describe Wright::Provider::User::Openbsd do
  describe '#system_user_option' do
    it 'should return the correct system option' do
      resource = OpenStruct.new(name: 'foo')
      user = Wright::Provider::User::Openbsd.new(resource)
      expected = '-r 100..999'
      actual = user.send(:system_user_option)
      actual.must_equal expected
    end
  end
end
