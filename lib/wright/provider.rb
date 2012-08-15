require 'wright/util/recursive_autoloader'

module Wright::Provider
  PROVIDER_DIR = File.expand_path('provider', File.dirname(__FILE__))
  Wright::Util::RecursiveAutoloader.add_autoloads(PROVIDER_DIR, self.name)
end
