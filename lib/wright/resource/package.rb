require 'wright/resource'
require 'wright/dsl'

module Wright
  class Resource
    # Package resource, represents a package.
    #
    # @example
    #   vim = Wright::Resource::Package.new('vim')
    #   vim.installed_versions
    #   # => []
    #   vim.install
    #   vim.installed_versions
    #   # => ["2:7.3.547-7"]
    #
    #   htop = Wright::Resource::Package.new('htop')
    #   htop.installed_versions
    #   # => ["1.0.1-1"]
    #   htop.remove
    #   htop.installed_versions
    #   # => []
    class Package < Wright::Resource
      # @return [String] the package version to install or remove
      attr_accessor :version

      # Initializes a Package.
      #
      # @param name [String] the package's name
      def initialize(name)
        super
        @version = nil
        @action = :install
      end

      # @return [Array<String>] the installed package versions
      def installed_versions
        @provider.installed_versions
      end

      # Installs the Package.
      #
      # @return [Bool] true if the package was updated and false
      #   otherwise
      def install
        might_update_resource do
          @provider.install
        end
      end

      # Removes the Package.
      #
      # @return [Bool] true if the package was updated and false
      #   otherwise
      def remove
        might_update_resource do
          @provider.remove
        end
      end

      alias_method :uninstall, :remove
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Package)

package_providers = {
  'debian' => 'Wright::Provider::Package::Apt',
  'macosx' => 'Wright::Provider::Package::Homebrew'
}
Wright::Config[:resources][:package] ||= {}
Wright::Config[:resources][:package][:provider] ||=
  package_providers[Wright::Util.os_family]
