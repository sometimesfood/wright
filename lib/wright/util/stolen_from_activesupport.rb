module Wright
  module Util
    # Makes an underscored, lowercase form from the expression in the string.
    #
    # Changes '::' to '/' to convert namespaces to paths.
    #
    # Examples:
    #   "ActiveModel".underscore         # => "active_model"
    #   "ActiveModel::Errors".underscore # => "active_model/errors"
    #
    # As a rule of thumb you can think of +underscore+ as the inverse of +camelize+,
    # though there are cases where that does not hold:
    #
    #   "SSLError".underscore.camelize # => "SslError"
    def self.underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    # By default, +camelize+ converts strings to UpperCamelCase. If the argument to +camelize+
    # is set to <tt>:lower</tt> then +camelize+ produces lowerCamelCase.
    #
    # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
    #
    # Examples:
    #   "active_record".camelize                # => "ActiveRecord"
    #   "active_record".camelize(:lower)        # => "activeRecord"
    #   "active_record/errors".camelize         # => "ActiveRecord::Errors"
    #   "active_record/errors".camelize(:lower) # => "activeRecord::Errors"
    #
    # As a rule of thumb you can think of +camelize+ as the inverse of +underscore+,
    # though there are cases where that does not hold:
    #
    #   "SSLError".underscore.camelize # => "SslError"
    def self.camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end

    # Tries to find a constant with the name specified in the argument string:
    #
    #   "Module".constantize     # => Module
    #   "Test::Unit".constantize # => Test::Unit
    #
    # The name is assumed to be the one of a top-level constant, no matter whether
    # it starts with "::" or not. No lexical context is taken into account:
    #
    #   C = 'outside'
    #   module M
    #     C = 'inside'
    #     C               # => 'inside'
    #     "C".constantize # => 'outside', same as ::C
    #   end
    #
    # NameError is raised when the name is not in CamelCase or the constant is
    # unknown.
    def self.constantize(camel_cased_word)
      names = camel_cased_word.split('::')
      names.shift if names.empty? || names.first.empty?

      constant = Object
      names.each do |name|
        constant = constant.const_defined?(name, false) ? constant.const_get(name) : constant.const_missing(name)
      end
      constant
    end

    # Tries to find a constant with the name specified in the argument string:
    #
    #   "Module".safe_constantize     # => Module
    #   "Test::Unit".safe_constantize # => Test::Unit
    #
    # The name is assumed to be the one of a top-level constant, no matter whether
    # it starts with "::" or not. No lexical context is taken into account:
    #
    #   C = 'outside'
    #   module M
    #     C = 'inside'
    #     C                    # => 'inside'
    #     "C".safe_constantize # => 'outside', same as ::C
    #   end
    #
    # nil is returned when the name is not in CamelCase or the constant (or part of it) is
    # unknown.
    #
    #   "blargle".safe_constantize  # => nil
    #   "UnknownModule".safe_constantize  # => nil
    #   "UnknownModule::Foo::Bar".safe_constantize  # => nil
    #
    def self.safe_constantize(camel_cased_word)
      begin
        constantize(camel_cased_word)
      rescue NameError => e
        raise unless e.message =~ /(uninitialized constant|wrong constant name) #{const_regexp(camel_cased_word)}$/ ||
          e.name.to_s == camel_cased_word.to_s
      end
    end

    # Mount a regular expression that will match part by part of the constant.
    # For instance, Foo::Bar::Baz will generate Foo(::Bar(::Baz)?)?
    def self.const_regexp(camel_cased_word) #:nodoc:
      parts = camel_cased_word.split("::")
      last  = parts.pop

      parts.reverse.inject(last) do |acc, part|
        part.empty? ? acc : "#{part}(::#{acc})?"
      end
    end
  end
end
