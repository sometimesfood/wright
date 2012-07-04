require_relative 'spec_helper'

require 'wright/resource_base'

module Wright
  module Providers
    class FooBar
      OUTPUT = 'I was initialized and all I got was this lousy T-shirt.'
      def initialize
        puts OUTPUT
      end
    end
  end
end

class Wright::Providers::Broken
  def initialize
    raise RuntimeError.new("I'm broken and should not be instantiated.")
  end
end

describe Wright::ResourceBase do
  before(:each) do
    Wright::Config.clear
  end

  it 'should retrieve a provider for a resource' do
    class FooBar < Wright::ResourceBase; end

    output = "#{Wright::Providers::FooBar::OUTPUT}\n"
    proc { FooBar.new(:something) }.must_output(output)
  end

  it 'should retrieve a provider for a resource listed in the config' do
    class Broken < Wright::ResourceBase; end

    # instantiating the Broken resource without config yields the
    # Broken provider
    proc { Broken.new(:something) }.must_raise(RuntimeError)

    # when the provider for Broken resources is set to FooBar,
    # FooBar should be instantiated
    foobar = 'Wright::Providers::FooBar'
    Wright::Config[:resources] = { broken: {provider: foobar } }
    output = "#{Wright::Providers::FooBar::OUTPUT}\n"
    proc { Broken.new(:something) }.must_output(output)
  end

  it 'should display warnings for nonexistent providers' do
    class NonExistent < Wright::ResourceBase; end
    output = "Warning: Could not find a provider for resource NonExistent\n"
    proc { NonExistent.new(:something) }.must_output(output)
  end
end
