require 'wright/resource'
require 'wright/dsl'

module Wright
  class Resource
    # Public: Package resource, represents a package.
    #
    # Examples
    #
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
      # Public: Get/Set the package version to install/remove.
      attr_accessor :version

      # Public: Initialize a Package.
      #
      # name - The package name.
      def initialize(name)
        super
        @version = nil
        @action = :install
      end

      # Public: Get the installed version of a package.
      #
      # Returns an array of installed package version Strings.
      def installed_versions
        @provider.installed_versions
      end

      # Public: Install the Package.
      #
      # Returns true if the package was updated and false otherwise.
      def install
        might_update_resource do
          @provider.install
        end
      end

      # Public: Remove the Package.
      #
      # Returns true if the package was updated and false otherwise.
      def remove
        might_update_resource do
          @provider.remove
        end
      end
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Package)
