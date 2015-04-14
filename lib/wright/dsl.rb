require 'wright/util'

module Wright
  # Includable Wright script DSL.
  #
  # Contains resource methods for all registered resources.
  #
  # @example
  #   # define a new resource at runtime
  #   class KitchenSink < Wright::Resource; end
  #
  #   # register the resource
  #   Wright::DSL.register_resource KitchenSink
  #
  #   extend Wright::DSL
  #
  #   kitchen_sink "I don't do anything"
  #
  #   # resource methods accept blocks
  #   kitchen_sink 'I am sooo useful' do |k|
  #     puts k.name
  #   end
  #   # output: I am sooo useful
  #
  #   # save resource for later use
  #   a_sink_to_remember = kitchen_sink 'Me too, me too!'
  #   a_sink_to_remember.class
  #   # => KitchenSink
  module DSL
    # Registers a class as a resource.
    #
    # Creates a resource method in the DSL module. Uses the
    # snake-cased class name as method name.
    #
    # Typically resource_class is a subclass of {Resource}. It is
    # initialized with the resource's name as an argument.
    #
    # @param resource_class the resource class
    #
    # @return [void]
    def self.register_resource(resource_class)
      method_name = Util.class_to_resource_name(resource_class)
      this_module = self
      define_method(method_name) do |name, &block|
        this_module.yield_resource(resource_class, name, &block)
      end
    end

    # @api private
    # Instantiates a resource and performs its default action.
    #
    # Implicitly invoking a block from within another block does not
    # work: http://blog.sidu.in/2007/11/ruby-blocks-gotchas.html
    #
    # @yield [Resource] the resource
    # @return [void]
    def self.yield_resource(resource_class, name)
      r = resource_class.new(name)
      yield(r) if block_given?
      r.run_action if r.respond_to?(:run_action)
      r
    end
  end
end
