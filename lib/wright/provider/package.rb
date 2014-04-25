require 'wright/provider'

module Wright
  class Provider
    # Public: Package provider. Used as a Provider base class for
    # Resource::Package.
    class Package < Wright::Provider
      private

      # Public: Check if the package is up-to-date for a given
      # action.
      #
      # action - The action symbol. Currently supports :install and
      #          :remove.
      #
      # Returns true if the package is up-to-date and false otherwise.
      # Raises ArgumentError if the action is invalid.
      def uptodate?(action)
        case action
        when :install
          package_installed?
        when :remove
          !package_installed?
        else
          fail ArgumentError, "invalid action '#{action}'"
        end
      end

      def package_installed?
        if @resource.version
          installed_versions.include?(@resource.version)
        else
          !installed_versions.empty?
        end
      end
    end
  end
end
