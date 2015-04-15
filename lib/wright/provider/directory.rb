require 'fileutils'
require 'wright/provider'
require 'wright/util/file'
require 'wright/util/user'
require 'wright/util/file_permissions'

module Wright
  class Provider
    # Directory provider. Used as a provider for {Resource::Directory}.
    class Directory < Wright::Provider
      # Creates or updates the directory.
      #
      # @return [void]
      def create
        fail Errno::EEXIST, dirname if regular_file?

        dir = @resource.name
        unless_uptodate(:create, "directory already created: '#{dir}'") do
          create_directory
        end
      end

      # Removes the directory.
      #
      # @return [void]
      def remove
        if ::File.exist?(dirname) && !::File.directory?(dirname)
          fail "'#{dirname}' exists but is not a directory"
        end

        dir = @resource.name
        unless_uptodate(:remove, "directory already removed: '#{dir}'") do
          remove_directory
        end
      end

      private

      def uptodate?(action)
        case action
        when :create
          ::File.directory?(dirname) && permissions.uptodate?
        when :remove
          !::File.exist?(dirname) && !::File.directory?(dirname)
        end
      end

      def permissions
        Wright::Util::FilePermissions.create_from_resource(@resource,
                                                           :directory)
      end

      def create_directory
        dir_permissions = permissions
        unless_dry_run("create directory: '#{@resource.name}'") do
          FileUtils.mkdir_p(dirname)
          dir_permissions.update unless dir_permissions.uptodate?
        end
      end

      def remove_directory
        unless_dry_run("remove directory: '#{@resource.name}'") do
          FileUtils.rmdir(dirname)
        end
      end

      def regular_file?
        ::File.exist?(dirname) && !::File.directory?(dirname)
      end

      def dirname
        ::File.expand_path(@resource.name)
      end
    end
  end
end
