# The code in this file is largely copied from PencilMustache by
# Benjamin Oakes. The original code can be found at
# https://github.com/benjaminoakes/pencil_mustache.
#
# The following is a verbatim copy of the original license (MIT):
#
#   Copyright (c) 2012 Benjamin Oakes
#
#   Permission is hereby granted, free of charge, to any person obtaining
#   a copy of this software and associated documentation files (the
#   "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so, subject to
#   the following conditions:
#
#   The above copyright notice and this permission notice shall be
#   included in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Wright
  module Util
    # PencilMustache class.
    #
    # @example
    #   pencil_mustache = Wright::Util::PencilMustache.new
    #   template = "foo is {{foo}}."
    #   hash = { foo: :bar }
    #   pencil_mustache.render(template, hash)
    #   # => "foo is bar."
    class PencilMustache
      # Renders a Mustache template using the supplied hash.
      # @param template [String] the template
      # @param hash [Hash] the hash
      # @return [String] the rendered template
      # @todo Raise NameError if necessary.
      # @todo Add support for triple whiskers.
      def render(template, hash)
        template.gsub(/{{.*?}}/, add_whiskers(hash))
      end

      private

      def add_whiskers(doc)
        with_whiskers = {}
        doc.keys.each { |k| with_whiskers["{{#{k}}}"] = doc[k] }
        with_whiskers
      end
    end
  end
end
