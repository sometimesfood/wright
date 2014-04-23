require 'wright/provider'

module Wright
  class Provider
    # Public: Package provider. Used as a Provider base class for
    # Resource::Package.
    class Package < Wright::Provider
      def uptodate?(action)
        case action
        when :install
          !installed_version.nil?
        when :remove
          installed_version.nil?
        else
          fail ArgumentError, "invalid action '#{action}'"
        end
      end
    end
  end
end
