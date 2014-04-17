require 'wright/resource'
require 'wright/dsl'

module Wright
  class Resource
    # Public: Package resource, represents a package.
    #
    # Examples
    #
    #   package = Wright::Resource::Package.new('fortune')
    #   package.install
    class Package < Wright::Resource
      # Public: Get/Set the package version.
      attr_accessor :version

      # Public: Initialize a Package.
      #
      # name - The package name.
      def initialize(name)
        super
        @version = nil
        @action = :install
      end

      def installed_version
        @provider.installed_version
      end

      # Public: Install the Package.
      #
      # Returns true if the file was updated and false otherwise.
      def install
        might_update_resource do
          @provider.install
        end
      end

      # Public: Remove the Package.
      #
      # Returns true if the file was updated and false otherwise.
      def remove
        might_update_resource do
          @provider.remove
        end
      end
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Package)

# hard-coded for now
# TODO: remove this
Wright::Config[:resources] ||= Hash.new
Wright::Config[:resources][:package] =
  { provider: 'Wright::Provider::Package::Apt' }
