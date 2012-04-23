require 'wright/util'

module Wright
  module Resource
    def self.register(resource_class)
      method_name = Util.class_to_resource_name(resource_class)
      define_method(method_name) do |name, &block|
        Resource.yield_resource(resource_class, name, &block)
      end
    end

    private
    def self.yield_resource(resource_class, name, &block)
      r = resource_class.new(name)
      yield(r)
      r
    end
  end
end
