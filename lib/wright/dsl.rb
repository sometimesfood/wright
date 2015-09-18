require 'wright/util'
require 'wright/util/erb_renderer'
require 'wright/util/mustache_renderer'
require 'wright/util/file_renderer'

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
    # DSL helper class.
    class Util
      # Renders an ERB template using the supplied hash.
      # @param template [String] the template
      # @param hash [Hash] the hash
      # @return [String] the rendered template
      def render_erb(template, hash)
        Wright::Util::ErbRenderer.new(hash).render(template)
      end

      # Renders a mustache template using the supplied hash.
      # @param template [String] the template
      # @param hash [Hash] the hash
      # @return [String] the rendered template
      def render_mustache(template, hash)
        Wright::Util::MustacheRenderer.new(hash).render(template)
      end

      # Renders a template file according to the file's extension
      # using the supplied hash. Currently supports ERB (+.erb+) and
      # Mustache (+.mustache+).
      #
      # @param filename [String] the filename of the template file
      # @param hash [Hash] the hash
      # @return [String] the rendered template
      def render_file(filename, hash)
        Wright::Util::FileRenderer.new(hash).render(filename)
      end
    end

    # Supplies access to various useful helper methods.
    # @return [Wright::DSL::Util] a utility helper
    def util
      Wright::DSL::Util.new
    end

    # Registers a class as a resource.
    #
    # Creates a resource method in the DSL module. Uses the
    # snake-cased class name as method name.
    #
    # Typically +resource_class+ is a subclass of {Resource}. It is
    # initialized with the resource's name and the attribute hash as
    # arguments.
    #
    # @param resource_class [Class] the resource class
    # @return [void]
    def self.register_resource(resource_class)
      method_name = Wright::Util.class_to_resource_name(resource_class)
      this_module = self
      define_method(method_name) do |name, args = {}, &block|
        this_module.yield_resource(resource_class, name, args, &block)
      end
    end

    # @api private
    # Instantiates a resource and performs its default action.
    #
    # Implicitly invoking a block from within another block does not
    # work: http://blog.sidu.in/2007/11/ruby-blocks-gotchas.html
    #
    # @param resource_class [Class] the resource class
    # @param name [String] the name of the resource object
    # @param args [Hash<Symbol, Object] the attribute hash of the resource
    #
    # @yield [Resource] the resource
    # @return [void]
    def self.yield_resource(resource_class, name, args)
      r = resource_class.new(name, args)
      yield(r) if block_given?
      r.run_action if r.respond_to?(:run_action)
      r
    end
  end
end
