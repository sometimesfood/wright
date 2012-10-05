require 'wright/util/recursive_autoloader'

# Public: Provider class.
class Wright::Provider
  # Public: Wright standard provider directory.
  PROVIDER_DIR = File.expand_path('provider', File.dirname(__FILE__))

  Wright::Util::RecursiveAutoloader.add_autoloads(PROVIDER_DIR, self.name)

  # Public: Initialize a Provider.
  #
  # resource - The resource used by the provider, typically a Wright::Resource.
  def initialize(resource)
    @resource = resource
    @updated = false
  end

  # Public: Checks if the provider was updated since the last call to updated?.
  #
  # Returns true if the provider was updated and false otherwise.
  def updated?
    updated = @updated
    @updated = false
    updated
  end
end
