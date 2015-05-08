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
        fail Errno::EEXIST, dirname_expanded if regular_file?

        dir_permissions = permissions
        unless_uptodate(:create, "directory already created: '#{dir_name}'") do
          unless_dry_run("create directory: '#{dir_name}'") do
            FileUtils.mkdir_p(dirname_expanded)
            dir_permissions.update unless dir_permissions.uptodate?
          end
        end
      end

      # Removes the directory.
      #
      # @return [void]
      def remove
        if ::File.exist?(dirname_expanded) &&
           !::File.directory?(dirname_expanded)
          fail "'#{dirname_expanded}' exists but is not a directory"
        end

        unless_uptodate(:remove, "directory already removed: '#{dir_name}'") do
          unless_dry_run("remove directory: '#{dir_name}'") do
            FileUtils.rmdir(dirname_expanded)
          end
        end
      end

      private

      def dir_name
        @resource.name
      end

      def permissions
        Wright::Util::FilePermissions.create_from_resource(@resource,
                                                           :directory)
      end

      def uptodate?(action)
        case action
        when :create
          ::File.directory?(dirname_expanded) && permissions.uptodate?
        when :remove
          !::File.exist?(dirname_expanded) &&
            !::File.directory?(dirname_expanded)
        end
      end

      def regular_file?
        ::File.exist?(dirname_expanded) && !::File.directory?(dirname_expanded)
      end

      def dirname_expanded
        ::File.expand_path(dir_name)
      end
    end
  end
end
