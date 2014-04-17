require 'wright/provider/package'

module Wright
  class Provider
    class Package
      # Public: AptPackage provider. Used as a Provider for
      # Resource::Package on Debian-based systems.
      class Apt < Wright::Provider::Package
      end
    end
  end
end
