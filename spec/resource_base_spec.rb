require_relative 'spec_helper'

require 'wright/resource_base'

COMPLAINT = 'I was initialized and all I got was this lousy'
THANKS = 'Great souvenir, thanks!'

module Wright
  module Providers
    class Souvenir
      def initialize(resource)
        souvenir = resource.name
        @complaint = "#{COMPLAINT} #{souvenir}."
      end
      attr_reader :complaint
    end

    class AlternateSouvenir
      def initialize(resource); end
      def complaint; THANKS; end
    end
  end
end

class Souvenir < Wright::ResourceBase
  def complaint; @provider.complaint; end
end

describe Wright::ResourceBase do
  before(:each) do
    Wright::Config.clear
  end

  it 'should retrieve a provider for a resource' do
    souvenir = :tshirt
    complaint = "#{COMPLAINT} #{souvenir}."
    Souvenir.new(souvenir).complaint.must_equal complaint
  end

  it 'should retrieve a provider for a resource listed in the config' do
    # instantiating the Souvenir resource without config yields the
    # Souvenir provider
    souvenir = :mug
    Souvenir.new(souvenir).complaint.must_equal "#{COMPLAINT} #{souvenir}."

    # when the provider for Souvenir resources is set to
    # AlternateSouvenir, AlternateSouvenir should be instantiated
    alternate = 'Wright::Providers::AlternateSouvenir'
    Wright::Config[:resources] = { souvenir: {provider: alternate } }
    Souvenir.new(:something).complaint.must_equal THANKS
  end

  it 'should display warnings for nonexistent providers' do
    class NonExistent < Wright::ResourceBase; end
    output = "WARN: Could not find a provider for resource NonExistent\n"
    proc do
      reset_logger
      NonExistent.new(:something)
    end.must_output(output)
  end
end
