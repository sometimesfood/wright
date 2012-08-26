require 'wright/util/recursive_autoloader'

module Wright::Provider
  # Public: Wright standard provider directory.
  PROVIDER_DIR = File.expand_path('provider', File.dirname(__FILE__))
  Wright::Util::RecursiveAutoloader.add_autoloads(PROVIDER_DIR, self.name)
end
