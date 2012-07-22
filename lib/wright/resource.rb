require 'wright/config'
require 'wright/util'
require 'wright/logger'

module Wright
  class Resource
    def initialize(name)
      @name = name
      @resource_name = Util.class_to_resource_name(self.class).to_sym
      @provider = provider_for_resource
      @action = nil
      @on_update = nil
    end

    attr_accessor :action, :on_update
    attr_reader :name

    def run_action
      if @action
        bang_action = "#{@action}!".to_sym
        action = respond_to?(bang_action) ? bang_action : @action
        send(action)
      end
    end

    private
    def run_update_action
      # TODO: maybe add some error checking; @on_update.respond_to?(:call)
      @on_update.call unless @on_update.nil?
    end

    def run_update_action_if_updated
      if @provider.respond_to?(:updated?)
        run_update_action if @provider.updated?
      else
        if @on_update
          warning = "Provider #{@provider.class.name} does not support updates"
          Wright.log.warn warning
        end
      end
    end

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
        klass.new(self)
      else
        warning = "Could not find a provider for resource #{resource_class}"
        Wright.log.warn warning
        nil
      end
    end
  end
end
