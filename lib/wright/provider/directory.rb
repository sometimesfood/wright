require 'fileutils'
require 'wright/provider'
require 'wright/util/file'
require 'wright/util/user'
require 'wright/util/file_permissions'

module Wright
  class Provider
    # Public: Directory provider. Used as a Provider for Resource::Directory.
    class Directory < Wright::Provider
      # Public: Create or update the directory.
      #
      # Returns nothing.
      def create
        if ::File.directory?(@resource.name) && permissions.uptodate?

          Wright.log.debug "directory already created: '#{@resource.name}'"
          return
        end

        if ::File.exist?(@resource.name) && !::File.directory?(@resource.name)
          fail Errno::EEXIST, @resource.name
        end
        create_directory
        @updated = true
      end

      # Public: Remove the directory.
      #
      # Returns nothing.
      def remove
        if ::File.exist?(@resource.name) && !::File.directory?(@resource.name)
          fail "'#{@resource.name}' exists but is not a directory"
        end

        if ::File.directory?(@resource.name)
          remove_directory
          @updated = true
        else
          Wright.log.debug "directory already removed: '#{@resource.name}'"
        end
      end

      private

      def permissions
        Wright::Util::FilePermissions.create_from_resource(@resource,
                                                           :directory)
      end

      def create_directory
        dirname = @resource.name
        dir_permissions = permissions

        if Wright.dry_run?
          Wright.log.info "(would) create directory: '#{dirname}'"
        else
          Wright.log.info "create directory: '#{dirname}'"
          FileUtils.mkdir_p(dirname)
          dir_permissions.update
        end
      end

      def remove_directory
        if Wright.dry_run?
          Wright.log.info "(would) remove directory: '#{@resource.name}'"
        else
          Wright.log.info "remove directory: '#{@resource.name}'"
          FileUtils.rmdir(@resource.name)
        end
      end
    end
  end
end
