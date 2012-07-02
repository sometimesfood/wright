require 'wright/util/recursive_autoloader'

module Wright::Providers
  PROVIDER_DIR = File.expand_path('providers', File.dirname(__FILE__))
  Wright::Util::RecursiveAutoloader.add_autoloads(PROVIDER_DIR, self.name)
end
