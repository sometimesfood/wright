require 'wright/provider'

module Wright
  class Provider
    # Public: Package provider. Used as a Provider base class for
    # Resource::Package.
    class Package < Wright::Provider
      def uptodate?
        !installed_version.nil?
      end
    end
  end
end
