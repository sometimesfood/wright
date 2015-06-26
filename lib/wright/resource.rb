require 'wright/config'
require 'wright/util'
require 'wright/logger'
require 'wright/dry_run'

module Wright
  # Resource base class.
  class Resource
    # Initializes a Resource.
    #
    # @param name [String] the name of the resource
    def initialize(name = nil, args = {})
      @name           = name
      @action         = args.fetch(:action, nil)
      @ignore_failure = args.fetch(:ignore_failure, false)
      self.on_update  = args.fetch(:on_update, nil)
      @resource_name  = Util.class_to_resource_name(self.class).to_sym
      @provider       = provider_for_resource
    end

    # @return [Symbol] the name of the method to be run by {#run_action}
    attr_accessor :action

    # @return [Bool] the ignore_failure attribute
    attr_accessor :ignore_failure

    # @return [String] the resource's name attribute
    #
    # @example
    #   foo = Wright::Resource::Symlink.new('/tmp/fstab')
    #   foo.name
    #   # => "/tmp/fstab"
    #
    #   bar = Wright::Resource::Symlink.new
    #   bar.name = '/tmp/passwd'
    #   bar.name
    #   # => "/tmp/passwd"
    attr_accessor :name

    # @return [Symbol] a compact resource name
    #
    # @example
    #   foo = Wright::Resource::Symlink.new
    #   foo.resource_name
    #   # => :symlink
    attr_reader :resource_name

    # Sets an update action for a resource.
    #
    # @param on_update [Proc, #call] the block that is called when the
    #   resource is updated.
    #
    # @return [void]
    # @raise [ArgumentError] if on_update is not callable
    def on_update=(on_update)
      if on_update.respond_to?(:call) || on_update.nil?
        @on_update = on_update
      else
        fail ArgumentError, "#{on_update} is not callable"
      end
    end

    # Runs the resource's current action.
    #
    # @example
    #   fstab = Wright::Resource::Symlink.new('/tmp/fstab')
    #   fstab.action = :remove
    #   fstab.run_action
    #
    # @return the return value of the current action
    def run_action
      send action if action
    end

    private

    attr_reader :on_update, :provider

    # @api public
    # Marks a code block that might update a resource.
    #
    # Usually this method is called in the definition of a new
    # resource class in order to mark those methods that should be
    # able to trigger update actions. Runs the current update action
    # if the provider was updated by the block method.
    #
    # @example
    #   class BalloonAnimal < Wright::Provider
    #     def inflate
    #       puts "It's a giraffe!"
    #       @updated = true
    #     end
    #   end
    #
    #   class Balloon < Wright::Resource
    #     def inflate
    #       might_update_resource { provider.inflate }
    #     end
    #   end
    #   Wright::Config[:resources] = { balloon: { provider: 'BalloonAnimal' } }
    #
    #   balloon = Balloon.new.inflate
    #   # => true
    #
    # @return [Bool] true if the provider was updated and false
    #   otherwise
    def might_update_resource
      begin
        yield
      rescue => e
        log_error(e)
        raise e unless ignore_failure
      end
      updated = provider.updated?
      run_update_action if updated
      updated
    end

    def log_error(exception)
      resource = "#{resource_name}"
      resource << " '#{name}'" if name
      Wright.log.error "#{resource}: #{exception}"
    end

    def run_update_action
      return unless on_update

      resource = "#{resource_name} '#{name}'"
      notification = "run update action for #{resource}"
      if Wright.dry_run?
        Wright.log.info "(would) #{notification}"
      else
        Wright.log.info notification
        on_update.call
      end
    end

    def resource_class
      Util::ActiveSupport.camelize(resource_name)
    end

    def provider_name
      if Wright::Config.nested_key?(:resources, resource_name, :provider)
        Wright::Config[:resources][resource_name][:provider]
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
