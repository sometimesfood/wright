require_relative 'spec_helper'

require 'wright/resource'
require 'wright/provider'

module Wright
  # add provider attribute reader for tests
  class Resource
    attr_reader :provider
  end
end

module Wright
  class Provider
    class Sample < Wright::Provider; end
    class AlternateSample < Wright::Provider; end

    # provider that is always updated
    class AlwaysUpdated < Wright::Provider
      def updated?
        true
      end
    end

    # provider that is never updated
    class NeverUpdated < Wright::Provider
      def updated?
        false
      end
    end
  end
end

class Sample < Wright::Resource; end

# resource with a single method to test update notification
class Updater < Wright::Resource
  def do_something
    might_update_resource {}
  end
end

describe Wright::Resource do
  before(:each) do
    @config = Wright::Config.config_hash.clone
    Wright::Config.config_hash.clear
    @hello = 'Hello world'
    @say_hello = -> { print @hello }
  end

  after(:each) do
    Wright::Config.config_hash = @config
  end

  it 'should retrieve a provider for a resource' do
    provider_class = Wright::Provider::Sample
    Sample.new.provider.must_be_kind_of provider_class
  end

  it 'should retrieve a provider for a resource listed in the config' do
    # instantiating the Sample resource without any config should
    # yield the Sample provider
    provider_class = Wright::Provider::Sample
    Sample.new.provider.must_be_kind_of provider_class

    # when the provider for Sample resources is set to
    # AlternateSample, AlternateSample should be instantiated
    alternate = Wright::Provider::AlternateSample
    Wright::Config[:resources] = { sample: { provider: alternate.name } }
    Sample.new.provider.must_be_kind_of alternate
  end

  it 'should display warnings for nonexistent providers' do
    class NonExistent < Wright::Resource; end
    output = "WARN: Could not find a provider for resource NonExistent\n"
    lambda do
      reset_logger
      NonExistent.new
    end.must_output(output)
  end

  it 'should run update actions on updates' do
    provider = Wright::Provider::AlwaysUpdated
    Wright::Config[:resources] = { updater: { provider: provider.name } }
    resource = Updater.new
    lambda do
      resource.on_update = @say_hello
      assert resource.do_something
    end.must_output @hello
  end

  it 'should not run update actions if there were no updates' do
    provider = Wright::Provider::NeverUpdated
    Wright::Config[:resources] = { updater: { provider: provider.name } }
    resource = Updater.new
    lambda do
      resource.on_update = @say_hello
      assert !resource.do_something
    end.must_be_silent
  end

  it 'should not run update actions in dry-run mode' do
    Wright.dry_run do
      provider = Wright::Provider::AlwaysUpdated
      Wright::Config[:resources] = { updater: { provider: provider.name } }
      name = :farnsworth
      resource = Updater.new(name)
      resource_info = "#{resource.resource_name} '#{name}'"
      output = "INFO: (would) run update action for #{resource_info}\n"
      lambda do
        reset_logger
        resource.on_update = @say_hello
        assert resource.do_something
      end.must_output output
    end
  end

  it 'should raise an ArgumentError if on_update is not callable' do
    resource = Sample.new
    -> { resource.on_update = "I'm a string" }.must_raise ArgumentError
    -> { resource.on_update = -> {} }.must_be_silent
    -> { resource.on_update = nil }.must_be_silent
  end

  it 'should run actions' do
    # simple resource to test different actions
    class NiSayer < Wright::Resource
      def say
        print 'Ni!'
      end

      def shout
        print 'NI!'
      end
    end
    Wright::Config[:resources] = { ni_sayer: { provider: 'Sample' } }
    ni_sayer = NiSayer.new
    lambda do
      ni_sayer.action = :say
      ni_sayer.run_action
    end.must_output 'Ni!'
    lambda do
      ni_sayer.action = :shout
      ni_sayer.run_action
    end.must_output 'NI!'
    lambda do
      ni_sayer.action = nil
      ni_sayer.run_action
    end.must_be_silent
  end

  it 'should not raise exceptions if ignore_failure is enabled' do
    module Wright
      class Provider
        # provider that always raises exceptions
        class RaisesExceptions < Wright::Provider
          def fail_train
            fail 'Fail train!'
          end
        end
      end
    end

    # resource that always raises exceptions
    class RaisesExceptions < Wright::Resource
      def fail_train
        might_update_resource { @provider.fail_train }
      end
    end

    resource = RaisesExceptions.new('fake_name')

    lambda do
      resource.ignore_failure = true
      reset_logger
      resource.fail_train
    end.must_output "ERROR: raises_exceptions 'fake_name': Fail train!\n"

    lambda do
      resource.ignore_failure = false
      resource.fail_train
    end.must_raise(RuntimeError)
  end
end
