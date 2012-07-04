require 'forwardable'

module Wright
  class Config
    @config_hash = {}
    class << self
      extend Forwardable
      def_delegators :@config_hash, :[], :[]=, :size
    end
    private_class_method :new

    def self.has_nested_key?(*path)
      last_key = path.pop
      last_hash = path.inject(@config_hash) do |hash, key|
        return false unless hash.respond_to?(:fetch)
        hash.fetch(key)
      end
      last_hash.respond_to?(:has_key?) && last_hash.has_key?(last_key)
    end
  end
end
