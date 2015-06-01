require 'forwardable'

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
      extend Forwardable

      # @return [String] the package version to install or remove
      attr_accessor :version

      # @return [String, Array<String>] the options passed to the
      #   package manager
      attr_accessor :options

      # Initializes a Package.
      #
      # @param name [String] the package's name
      def initialize(name)
        super
        @version = nil
        @options = nil
        @action = :install
      end

      # @!method installed_versions
      # @return [Array<String>] the installed package versions
      def_delegator :@provider, :installed_versions

      # @!method installed?
      # @return [Bool] +true+ if the package is installed
      def_delegator :@provider, :installed?

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
  'rhel'   => 'Wright::Provider::Package::Yum',
  'macosx' => 'Wright::Provider::Package::Homebrew'
}
Wright::Config[:resources][:package] ||= {}
Wright::Config[:resources][:package][:provider] ||=
  package_providers[Wright::Util.os_family]
