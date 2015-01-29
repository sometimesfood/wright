require 'forwardable'

module Wright
  # Configuration container, wraps a regular Ruby hash.
  #
  # Useful for getting and setting configuration values, such as
  # logging verbosity, color output and provider configuration.
  #
  # @example
  #   Wright::Config[:foo] = { bar: :baz }
  #   Wright::Config[:foo][:bar]
  #   # => :baz
  class Config
    @config_hash = {}
    class << self
      extend Forwardable
      def_delegators :@config_hash, :[], :[]=, :size
    end
    private_class_method :new

    # Checks if a (nested) configuration value is set.
    #
    # @param path [Array<Symbol>] the configuration key
    #
    # @example
    #   Wright::Config[:foo] = { bar: :baz }
    #   Wright::Config.nested_key?(:foo, :bar)
    #   # => true
    #
    #   Wright::Config.nested_key?(:this, :doesnt, :exist)
    #   # => false
    #
    # @return [Bool] true if the configuration value is set and false
    #   otherwise.
    def self.nested_key?(*path)
      last_key = path.pop
      last_hash = path.reduce(@config_hash) do |hash, key|
        return false unless hash.respond_to?(:fetch)
        hash.fetch(key, {})
      end
      last_hash.respond_to?(:key?) && last_hash.key?(last_key)
    end

    # Retrieves a (nested) configuration value.
    #
    # @param path [Array<Symbol>] the configuration key
    #
    # @example
    #   Wright::Config[:foo] = { bar: :baz }
    #   Wright::Config.nested_value(:foo, :bar)
    #   # => :baz
    #
    #   Wright::Config.nested_value(:this, :doesnt, :exist)
    #   # => nil
    #
    # @return the configuration value or nil if the value is not set
    def self.nested_value(*path)
      nested_key?(*path) ? path.reduce(@config_hash) { |a, e| a[e] } : nil
    end
  end
end

Wright::Config[:resources] ||= {}
