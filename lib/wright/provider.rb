require 'wright/util/recursive_autoloader'

module Wright
  # Public: Provider class.
  class Provider
    # Public: Wright standard provider directory.
    PROVIDER_DIR = File.expand_path('provider', File.dirname(__FILE__))

    Wright::Util::RecursiveAutoloader.add_autoloads(PROVIDER_DIR, name)

    # Public: Initialize a Provider.
    #
    # resource - The resource used by the provider, typically a
    #            Wright::Resource.
    def initialize(resource)
      @resource = resource
      @updated = false
    end

    # Public: Checks if the provider was updated since the last call
    #         to updated?.
    #
    # Returns true if the provider was updated and false otherwise.
    def updated?
      updated = @updated
      @updated = false
      updated
    end
  end
end
