require_relative 'spec_helper'

require 'wright/resource'

# add provider attribute reader for tests
class Wright::Resource
  attr_reader :provider
end

module Wright
  module Providers
    class Base
      def initialize(resource); end
    end

    class Sample < Base; end
    class AlternateSample < Base; end

    class AlwaysUpdated < Base
      def updated?; true; end
    end
    class NeverUpdated < Base
      def updated?; false; end
    end
  end
end

class Sample < Wright::Resource; end

class Updater < Wright::Resource
  def do_something; run_update_action_if_updated; end
end

describe Wright::Resource do
  before(:each) do
    Wright::Config.clear
    @hello = 'Hello world'
    @say_hello = proc { print @hello }
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

  it 'should run update actions on updates' do
    provider = Wright::Providers::AlwaysUpdated
    Wright::Config[:resources] = { updater: {provider: provider.name } }
    resource = Updater.new(:name)
    proc do
      resource.on_update = @say_hello
      resource.do_something
    end.must_output @hello
  end

  it 'should not run update actions if there were no updates' do
    provider = Wright::Providers::NeverUpdated
    Wright::Config[:resources] = { updater: {provider: provider.name } }
    resource = Updater.new(:name)
    proc do
      resource.on_update = @say_hello
      resource.do_something
    end.must_be_silent
  end

  it 'should display a warning if the provider does not support updates' do
    provider = Wright::Providers::Sample
    Wright::Config[:resources] = { updater: {provider: provider.name } }
    resource = Updater.new(:name)
    warning = "WARN: Provider #{provider.name} does not support updates\n"
    proc do
      reset_logger
      resource.on_update = @say_hello
      resource.do_something
    end.must_output warning
  end

  it 'should not display a warning if there is no update action defined' do
    provider = Wright::Providers::Sample
    Wright::Config[:resources] = { updater: {provider: provider.name } }
    resource = Updater.new(:name)
    proc do
      reset_logger
      resource.on_update = nil
      resource.do_something
    end.must_be_silent
  end

  it 'should raise an ArgumentError if on_update is not callable' do
    resource = Sample.new(:name)
    proc { resource.on_update = "I'm a string" }.must_raise ArgumentError
    proc { resource.on_update = Proc.new {} }.must_be_silent
    proc { resource.on_update = nil }.must_be_silent
  end

  it 'should run actions' do
    class NiSayer < Wright::Resource
      def say!; print 'Ni!'; end
      def say; raise RuntimeError.new('This should never be called'); end
      def shout; print 'NI!'; end
    end
    Wright::Config[:resources] = { ni_sayer: {provider: 'Sample' } }
    ni_sayer = NiSayer.new(:michael)
    proc do
      ni_sayer.action = :say
      ni_sayer.run_action
    end.must_output 'Ni!'
    proc do
      ni_sayer.action = :shout
      ni_sayer.run_action
    end.must_output 'NI!'
    proc do
      ni_sayer.action = nil
      ni_sayer.run_action
    end.must_be_silent
  end
end
