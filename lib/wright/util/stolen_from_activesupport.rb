# The functions in this file are based on Ruby on Rails' ActiveSupport
# toolkit, more specifically the Inflector module of Rails 4 found in
# activesupport/lib/active_support/inflector/methods.rb.
#
# The following is a verbatim copy of the original license:
#
#   Copyright (c) 2005-2014 David Heinemeier Hansson
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

module Wright #:nodoc:
  module Util
    # Internal: Various methods copied verbatim from ActiveSupport in
    #   order to keep dependencies to a minimum.
    module ActiveSupport
      # Internal: Convert a CamelCased String to underscored,
      #   lowercase form.
      #
      # Changes '::' to '/' to convert namespaces to paths.
      #
      # camel_cased_word - The String to be underscored.
      #
      # Examples
      #
      #   underscore("ActiveModel")
      #   # => "active_model"
      #
      #   underscore("ActiveModel::Errors")
      #   # => "active_model/errors"
      #
      # As a rule of thumb you can think of underscore as the inverse
      # of camelize, though there are cases where that does not hold:
      #
      #   camelize(underscore("SSLError"))
      #   # => "SslError"
      #
      # Returns the underscored String.
      def self.underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        word.tr!('-', '_')
        word.downcase!
        word
      end

      # Internal: Convert an underscored_string to UpperCamelCase.
      #
      # camelize will also convert '/' to '::' which is useful for
      #   converting paths to namespaces.
      #
      # s - The String to be camelized.
      #
      # Examples
      #
      #   camelize("active_record")
      #   # => "ActiveRecord"
      #
      #   camelize("active_record/errors")
      #   # => "ActiveRecord::Errors"
      #
      # As a rule of thumb you can think of camelize as the inverse of
      # underscore, though there are cases where that does not hold:
      #
      #   camelize(underscore("SSLError"))
      #   # => "SslError"
      #
      # Returns the camelized String.
      def self.camelize(s)
        s.to_s
          .gsub(/\/(.?)/) { "::#{Regexp.last_match[1].upcase}" }
          .gsub(/(?:^|_)(.)/) { Regexp.last_match[1].upcase }
      end

      # Internal: Find a constant with the name specified in the
      # argument string.
      #
      # camel_cased_word - The String name of the constant to find.
      #
      # Examples
      #
      #   constantize("Module")
      #   # => Module
      #
      #   constantize("Test::Unit")
      #   # => Test::Unit
      #
      # The name is assumed to be the one of a top-level constant, no
      # matter whether it starts with "::" or not. No lexical context
      # is taken into account:
      #
      #   C = 'outside'
      #   module M
      #     C = 'inside'
      #     C                # => 'inside'
      #     constantize("C") # => 'outside', same as ::C
      #   end
      #
      # Returns the constant.
      # Raises NameError if the constant name is not in CamelCase or
      #   the constant is unknown.
      def self.constantize(camel_cased_word)
        names = camel_cased_word.split('::')
        names.shift if names.empty? || names.first.empty?

        c = Object
        names.each do |name|
          const_defined = c.const_defined?(name, false)
          c = const_defined ? c.const_get(name) : c.const_missing(name)
        end
        c
      end

      # Internal: Find a constant with the name specified in the
      # argument string.
      #
      # camel_cased_word - The String name of the constant to find.
      #
      # Examples
      #
      #   constantize("Module")
      #   # => Module
      #
      #   constantize("Test::Unit")
      #   # => Test::Unit
      #
      # The name is assumed to be the one of a top-level constant, no
      # matter whether it starts with "::" or not. No lexical context
      # is taken into account:
      #
      #   C = 'outside'
      #   module M
      #     C = 'inside'
      #     C                # => 'inside'
      #     constantize("C") # => 'outside', same as ::C
      #   end
      #
      # nil is returned when the name is not in CamelCase or the
      # constant (or part of it) is unknown.
      #
      #   safe_constantize("blargle")
      #   # => nil
      #
      #   safe_constantize("UnknownModule")
      #   # => nil
      #
      #   safe_constantize("UnknownModule::Foo::Bar")
      #   # => nil
      #
      # Returns the constant or nil if the name is not in CamelCase or
      #   the constant is unknown.
      def self.safe_constantize(camel_cased_word)
        constantize(camel_cased_word)
      rescue NameError => e
        error_re = /(uninitialized constant|wrong constant name)/
        const_re = const_regexp(camel_cased_word)
        message_re = /#{error_re} #{const_re}$/
        uninitialized_constant_exception =
          e.message =~ message_re || e.name.to_s == camel_cased_word.to_s
        raise unless uninitialized_constant_exception
      end

      # Internal: Construct a regular expression that will match a
      # constant part by part.
      #
      # camel_cased_word - The CamelCased String constant name.
      #
      # Examples
      #
      #   const_regexp("Foo::Bar::Baz")
      #   # => "Foo(::Bar(::Baz)?)?"
      #
      # Returns the String to be used as a regular expression.
      def self.const_regexp(camel_cased_word)
        parts = camel_cased_word.split('::')
        last  = parts.pop

        parts.reverse.reduce(last) do |acc, part|
          part.empty? ? acc : "#{part}(::#{acc})?"
        end
      end
    end
  end
end
