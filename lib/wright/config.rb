require 'forwardable'

module Wright
  # Public: Configuration container, wraps a regular Ruby hash.
  #
  # Useful for getting and setting configuration values, such as
  # logging verbosity, colour output and provider configuration.
  #
  # Examples
  #
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

    # Public: Check if a (nested) configuration value is set.
    #
    # path - The configuration item as an argument list.
    #
    # Examples
    #
    #   Wright::Config[:foo] = { bar: :baz }
    #   Wright::Config.nested_key?(:foo, :bar)
    #   # => true
    #
    #   Wright::Config.nested_key?(:this, :doesnt, :exist)
    #   # => false
    #
    # Returns true if the configuration value is set and false
    #   otherwise.
    def self.nested_key?(*path)
      last_key = path.pop
      last_hash = path.reduce(@config_hash) do |hash, key|
        return false unless hash.respond_to?(:fetch)
        hash.fetch(key, {})
      end
      last_hash.respond_to?(:key?) && last_hash.key?(last_key)
    end

    # Public: Retrieve a (nested) configuration value.
    #
    # path - The configuration item as an argument list.
    #
    # Examples
    #
    #   Wright::Config[:foo] = { bar: :baz }
    #   Wright::Config.nested_value(:foo, :bar)
    #   # => :baz
    #
    #   Wright::Config.nested_value(:this, :doesnt, :exist)
    #   # => nil
    #
    # Returns the configuration value or nil if the value is not set.
    def self.nested_value(*path)
      nested_key?(*path) ? path.reduce(@config_hash) { |a, e| a[e] } : nil
    end
  end
end

Wright::Config[:resources] ||= {}
