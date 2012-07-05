require 'wright/util'

module Wright
  module Resource
    def self.register(resource_class)
      method_name = Util.class_to_resource_name(resource_class)
      this_module = self
      define_method(method_name) do |name = nil, &block|
        this_module.yield_resource(resource_class, name, &block)
      end
    end

    private
    def self.yield_resource(resource_class, name, &block)
      r = resource_class.new(name)
      yield(r) if block_given?
      if r.respond_to?(:default_action) && r.default_action.respond_to?(:call)
        r.default_action.call
      end
      r
    end
  end
end
