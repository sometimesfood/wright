require 'wright/config'
require 'wright/util'

module Wright
  class ResourceBase
    def initialize(name)
      @resource_name = Util.class_to_resource_name(self.class).to_sym
      @provider = provider_for_resource
    end

    private
    def provider_name
      if Wright::Config.has_nested_key?(:resources, @resource_name, :provider)
        Wright::Config[:resources][@resource_name][:provider]
      else
        "Wright::Providers::#{Util.camelize(@resource_name)}"
      end
    end

    def provider_for_resource
      klass = Util.safe_constantize(provider_name)
      klass.new unless klass.nil?
    end
  end
end
