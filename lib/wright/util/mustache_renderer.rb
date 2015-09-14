begin
  require 'mustache'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

require 'wright/util/pencil_mustache'

module Wright
  module Util
    # Mustache renderer.
    #
    # @example
    #   template = "foo is {{foo}}."
    #   hash = { foo: :bar }
    #   Wright::Util::MustacheRenderer.new(hash).render(template)
    #   # => "foo is bar."
    class MustacheRenderer
      def initialize(hash)
        @hash = hash
        @mustache = select_mustache
      end

      # Renders a Mustache template.
      # @param template [String] the template
      # @return [String] the rendered template
      def render(template)
        @mustache.render(template, @hash)
      end

      private

      def select_mustache
        return PencilMustache.new unless defined?(Mustache)

        mustache = Mustache.new
        mustache.raise_on_context_miss = true
        mustache
      end
    end
  end
end
