require 'forwardable'

module Wright
  class Config
    @config_hash = {}
    class << self
      extend Forwardable
      def_delegators :@config_hash, :[], :[]=, :size
    end
    private_class_method :new
  end
end
