module Wright
  class Config
    @config_hash = {}
    class << self
      extend Forwardable
      def_delegators :@config_hash, :[], :[]=, :size
    end
    private_class_method :new
  end

#  class Config
#    @@config = {}
#
#    def self.[](key)
#      @@config[key]
#    end
#
#    def self.[]=(key, value)
#      @@config[key] = value
#    end
#
#    def self.merge!(other_config)
#      @@config.merge!(other_config)
#    end
#  end
end
