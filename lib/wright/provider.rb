require 'wright/util/recursive_autoloader'

class Wright::Provider
  # Public: Wright standard provider directory.
  PROVIDER_DIR = File.expand_path('provider', File.dirname(__FILE__))
  Wright::Util::RecursiveAutoloader.add_autoloads(PROVIDER_DIR, self.name)

  def initialize(resource)
    @resource = resource
    @updated = false
  end

  def updated?
    updated = @updated
    @updated = false
    updated
  end
end
