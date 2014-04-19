require_relative 'spec_helper'

require 'wright/provider'

# fake provider
class FakeProvider < Wright::Provider
  def initialize
    super(nil)
    @updated = true
  end
end

describe Wright::Provider do
  it 'should reset the updated attribute after checks' do
    provider = FakeProvider.new
    provider.updated?.must_equal true
    provider.updated?.must_equal false
  end
end
