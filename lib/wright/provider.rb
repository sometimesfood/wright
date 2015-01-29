require 'wright/config'
require 'wright/util/recursive_autoloader'

module Wright
  # Provider class.
  class Provider
    # Wright standard provider directory
    PROVIDER_DIR = File.expand_path('provider', File.dirname(__FILE__))

    Wright::Util::RecursiveAutoloader.add_autoloads(PROVIDER_DIR, name)

    # Initializes a Provider.
    #
    # @param resource [Resource] the resource used by the provider
    def initialize(resource)
      @resource = resource
      @updated = false
    end

    # Checks if the provider was updated since the last call to
    # {#updated?}
    #
    # @return [Bool] true if the provider was updated and false
    #   otherwise
    def updated?
      updated = @updated
      @updated = false
      updated
    end
  end
end
