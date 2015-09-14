require 'erb'

module Wright
  module Util
    # ERB renderer.
    #
    # @example
    #   template = "foo is <%= foo %>."
    #   hash = { foo: :bar }
    #   Wright::Util::ErbRenderer.new(hash).render(template)
    #   # => "foo is bar."
    class ErbRenderer
      def initialize(hash)
        hash.each do |k, v|
          instance_var = "@#{k}"
          instance_variable_set(instance_var, v)
          define_singleton_method(k) { instance_variable_get(instance_var) }
        end
      end

      # Renders an ERB template.
      # @param template [String] the template
      # @return [String] the rendered template
      def render(template)
        ERB.new(template).result(binding)
      end
    end
  end
end
