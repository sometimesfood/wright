require_relative 'spec_helper'

require 'wright/resource'

# add provider attribute reader for tests
class Wright::Resource
  attr_reader :provider
end

module Wright
  module Providers
    class Sample
      def initialize(resource); end
    end
    class AlternateSample
      def initialize(resource); end
    end
  end
end

class Sample < Wright::Resource; end

describe Wright::Resource do
  before(:each) do
    Wright::Config.clear
  end

  it 'should retrieve a provider for a resource' do
    provider_class = Wright::Providers::Sample
    Sample.new(:name).provider.must_be_kind_of provider_class
  end

  it 'should retrieve a provider for a resource listed in the config' do
    # instantiating the Sample resource without any config should
    # yield the Sample provider
    provider_class = Wright::Providers::Sample
    Sample.new(:name).provider.must_be_kind_of provider_class

    # when the provider for Sample resources is set to
    # AlternateSample, AlternateSample should be instantiated
    alternate = Wright::Providers::AlternateSample
    Wright::Config[:resources] = { sample: {provider: alternate.name } }
    Sample.new(:name).provider.must_be_kind_of alternate
  end

  it 'should display warnings for nonexistent providers' do
    class NonExistent < Wright::Resource; end
    output = "WARN: Could not find a provider for resource NonExistent\n"
    proc do
      reset_logger
      NonExistent.new(:something)
    end.must_output(output)
  end
end
