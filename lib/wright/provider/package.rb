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
        if uptodate?(:install)
          Wright.log.debug "package already installed: '#{@resource.name}'"
          return
        end

        install_package
        @updated = true
      end

      # Removes the package.
      #
      # @return [void]
      def remove
        if uptodate?(:remove)
          Wright.log.debug "package already removed: '#{@resource.name}'"
          return
        end

        remove_package
        @updated = true
      end

      private

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
