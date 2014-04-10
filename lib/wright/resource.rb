require 'wright/config'
require 'wright/util'
require 'wright/logger'
require 'wright/dry_run'

module Wright

  # Public: Resource base class.
  class Resource

    # Public: Initialize a Resource.
    #
    # name - The resource's name.
    def initialize(name = nil)
      @name = name
      @resource_name = Util.class_to_resource_name(self.class).to_sym
      @provider = provider_for_resource
      @action = nil
      @on_update = nil
      @ignore_failure = false
    end

    # Public: Get/Set the name Symbol of the method to be run by run_action.
    attr_accessor :action

    # Public: Get/Set the ignore_failure attribute.
    attr_accessor :ignore_failure

    # Public: Get/Set the resource's name attribute.
    #
    # Examples
    #
    #   foo = Wright::Resource::Symlink.new('/tmp/fstab')
    #   foo.name
    #   # => "/tmp/fstab"
    #
    #   bar = Wright::Resource::Symlink.new
    #   bar.name = '/tmp/passwd'
    #   bar.name
    #   # => "/tmp/passwd"
    attr_accessor :name

    # Public: Returns a compact resource name Symbol.
    #
    # Examples
    #
    #   foo = Wright::Resource::Symlink.new
    #   foo.resource_name
    #   # => :symlink
    attr_reader :resource_name

    # Public: Sets an update action for a resource.
    #
    # on_update - The block that is called if the resource is
    #             updated. Has to respond to :call.
    #
    # Returns nothing.
    # Raises ArgumentError if on_update is not callable
    def on_update=(on_update)
      if on_update.respond_to?(:call) || on_update.nil?
        @on_update = on_update
      else
        raise ArgumentError.new("#{on_update} is not callable")
      end
    end

    # Public: Runs the resource's current action.
    #
    # Examples
    #
    #   fstab = Wright::Resource::Symlink.new('/tmp/fstab')
    #   fstab.action = :remove!
    #   fstab.run_action
    def run_action
      if @action
        bang_action = "#{@action}!".to_sym
        action = respond_to?(bang_action) ? bang_action : @action
        send(action)
      end
    end

    private
    # Public: This is not documented yet.
    #
    # Returns true if the provider was updated and false otherwise.
    def might_update_resource #:doc:
      begin
        yield
      rescue => e
        resource = "#{@resource_name}"
        resource << " '#{@name}'" if @name
        Wright.log.error "#{resource}: #{e}"
        raise e unless @ignore_failure
      end
      updated = @provider.updated?
      run_update_action if updated
      updated
    end

    def run_update_action
      unless @on_update.nil?
        if Wright.dry_run?
          resource = "#{@resource_name} '#{@name}'"
          Wright.log.info "Would trigger update action for #{resource}"
        else
          @on_update.call
        end
      end
    end

    def resource_class
      Util::ActiveSupport.camelize(@resource_name)
    end

    def provider_name
      if Wright::Config.has_nested_key?(:resources, @resource_name, :provider)
        Wright::Config[:resources][@resource_name][:provider]
      else
        "Wright::Provider::#{resource_class}"
      end
    end

    def provider_for_resource
      klass = Util::ActiveSupport.safe_constantize(provider_name)
      if klass
        klass.new(self)
      else
        warning = "Could not find a provider for resource #{resource_class}"
        Wright.log.warn warning
        nil
      end
    end
  end
end
