require_relative '../../spec_helper'

require 'wright/provider/group/openbsd'
require 'fakeetc'

describe Wright::Provider::Group::Openbsd do
  describe '#system_group_option' do
    it 'should return the correct system option' do
      resource = OpenStruct.new(name: 'foo')
      group = Wright::Provider::Group::Openbsd.new(resource)
      expected = '-g 100'
      FakeEtc do
        actual = group.send(:system_group_option)
        actual.must_equal expected
      end
    end
  end
end
