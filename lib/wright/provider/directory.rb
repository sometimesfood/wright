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
        if ::File.directory?(dirname) && permissions.uptodate?
          Wright.log.debug "directory already created: '#{@resource.name}'"
          return
        end

        fail Errno::EEXIST, dirname if regular_file?
        create_directory
        @updated = true
      end

      # Public: Remove the directory.
      #
      # Returns nothing.
      def remove
        if ::File.exist?(dirname) && !::File.directory?(dirname)
          fail "'#{dirname}' exists but is not a directory"
        end

        if ::File.directory?(dirname)
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
        dir_permissions = permissions

        if Wright.dry_run?
          Wright.log.info "(would) create directory: '#{@resource.name}'"
        else
          Wright.log.info "create directory: '#{@resource.name}'"
          FileUtils.mkdir_p(dirname)
          dir_permissions.update
        end
      end

      def remove_directory
        if Wright.dry_run?
          Wright.log.info "(would) remove directory: '#{@resource.name}'"
        else
          Wright.log.info "remove directory: '#{@resource.name}'"
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
