module Wright
  module Util

    # Internal: Various methods copied verbatim from ActiveSupport in
    # order to keep dependencies to a minimum.
    module ActiveSupport

      # Internal: Convert a CamelCased String to underscored, lowercase
      # form.
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
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end

      # Internal: Convert an underscored_string to UpperCamelCase.
      #
      # camelize will also convert '/' to '::' which is useful for
      # converting paths to namespaces.
      #
      # lower_case_and_underscored_word - The String to be camelized.
      # first_letter_in_uppercase - If first_letter_in_uppercase is
      #                             set to false, camelize produces
      #                             lowerCamelCase.
      #
      # Examples
      #
      #   camelize("active_record")
      #   # => "ActiveRecord"
      #
      #   camelize("active_record", :lower)
      #   # => "activeRecord"
      #
      #   camelize("active_record/errors")
      #   # => "ActiveRecord::Errors"
      #
      #   camelize("active_record/errors", :lower)
      #   # => "activeRecord::Errors"
      #
      # As a rule of thumb you can think of camelize as the inverse of
      # underscore, though there are cases where that does not hold:
      #
      #   camelize(underscore("SSLError"))
      #   # => "SslError"
      #
      # Returns the camelized String.
      def self.camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
        if first_letter_in_uppercase
          lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
        else
          lower_case_and_underscored_word.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..-1]
        end
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

        constant = Object
        names.each do |name|
          constant = constant.const_defined?(name, false) ? constant.const_get(name) : constant.const_missing(name)
        end
        constant
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
        begin
          constantize(camel_cased_word)
        rescue NameError => e
          raise unless e.message =~ /(uninitialized constant|wrong constant name) #{const_regexp(camel_cased_word)}$/ ||
            e.name.to_s == camel_cased_word.to_s
        end
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
        parts = camel_cased_word.split("::")
        last  = parts.pop

        parts.reverse.inject(last) do |acc, part|
          part.empty? ? acc : "#{part}(::#{acc})?"
        end
      end
    end
  end
end
