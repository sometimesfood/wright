require_relative 'spec_helper'

require 'wright/provider'

describe Wright::Provider do
  it 'should reset the updated attribute after checks' do
    class FakeProvider < Wright::Provider
      def initialize
        super(nil)
        @updated = true
      end
    end

    provider = FakeProvider.new
    assert  provider.updated?
    assert !provider.updated?
  end
end
