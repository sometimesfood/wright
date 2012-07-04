require 'wright/config'
require 'wright/util'

module Wright
  class ResourceBase
    def initialize(name)
      @resource_name = Util.class_to_resource_name(self.class).to_sym
      @provider = provider_for_resource
    end

    private
    def resource_class
      Util.camelize(@resource_name)
    end

    def provider_name
      if Wright::Config.has_nested_key?(:resources, @resource_name, :provider)
        Wright::Config[:resources][@resource_name][:provider]
      else
        "Wright::Providers::#{resource_class}"
      end
    end

    def provider_for_resource
      klass = Util.safe_constantize(provider_name)
      if klass
        klass.new
      else
        # TODO: use a proper logger for this
        puts "Warning: Could not find a provider for resource #{resource_class}"
        nil
      end
    end
  end
end
