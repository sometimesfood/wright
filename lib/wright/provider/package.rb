require 'wright/provider'

module Wright
  class Provider
    # Package provider. Used as a base class for Resource::Package
    # providers.
    class Package < Wright::Provider
      # Installs the package.
      #
      # @return [void]
      def install
        unless_uptodate(:install,
                        "package already installed: '#{package_name}'") do
          unless_dry_run("install package: '#{package_name}'") do
            install_package
          end
        end
      end

      # Removes the package.
      #
      # @return [void]
      def remove
        unless_uptodate(:remove,
                        "package already removed: '#{package_name}'") do
          unless_dry_run("remove package: '#{package_name}'") do
            remove_package
          end
        end
      end

      # @return [Array<String>] the installed package versions
      def installed_versions
        fail NotImplementedError
      end

      # @return [Bool] true if the package is installed, false
      #   otherwise
      def installed?
        if package_version
          installed_versions.include?(package_version)
        else
          !installed_versions.empty?
        end
      end

      private

      def package_name
        resource.name
      end

      def package_version
        resource.version
      end

      def package_options
        resource.options
      end

      # @api public
      # Checks if the package is up-to-date for a given action.
      #
      # @param action [Symbol] the action. Currently supports
      #   +:install+ and +:remove+.
      #
      # @return [Bool] +true+ if the package is up-to-date and +false+
      #   otherwise
      # @raise [ArgumentError] if the action is invalid
      def uptodate?(action)
        case action
        when :install
          installed?
        when :remove
          !installed?
        else
          fail ArgumentError, "invalid action '#{action}'"
        end
      end

      def install_package
        fail NotImplementedError
      end

      def remove_package
        fail NotImplementedError
      end
    end
  end
end
