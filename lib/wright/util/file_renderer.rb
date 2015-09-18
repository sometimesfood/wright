require 'wright/util/erb_renderer'
require 'wright/util/mustache_renderer'

module Wright
  module Util
    # File template class.
    #
    # @example
    #   filename = 'template.erb'
    #   template = "foo is <%= foo %>."
    #   hash = { foo: :bar }
    #   File.write(filename, template)
    #   file_template = Wright::Util::FileTemplate.new(filename, hash)
    #   file_template.render
    #   # => "foo is bar."
    class FileRenderer
      # Initializes a FileTemplate.
      # @param filename [String] the filename of the template
      # @param hash [Hash] the attribute hash of the template
      def initialize(hash)
        @hash = hash
      end

      # Renders the file template.
      # @raise [ArgumentError] if the given file type is not supported
      def render(filename)
        renderer = renderer_for_file(filename)
        template = ::File.read(::File.expand_path(filename))
        renderer.render(template)
      end

      private

      attr_reader :hash

      FILE_RENDERERS = {
        '.erb' => ErbRenderer,
        '.mustache' => MustacheRenderer
      }

      def renderer_for_file(filename)
        file_extension = ::File.extname(filename)
        rendering_class = FILE_RENDERERS[file_extension]
        unknown_template_type = "unknown template type '#{file_extension}'"
        fail ArgumentError, unknown_template_type unless rendering_class
        rendering_class.new(hash)
      end
    end
  end
end
