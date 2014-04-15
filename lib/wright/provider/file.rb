require 'wright/provider'
require 'wright/util/file_permissions'
require 'wright/util/user'
require 'fileutils'
require 'digest'
require 'tempfile'
require 'tmpdir'

module Wright
  class Provider
    # Public: File provider. Used as a Provider for Resource::File.
    class File < Wright::Provider
      # Public: Create or update the File.
      #
      # Returns nothing.
      def create!
        fail Errno::EISDIR, @resource.name if ::File.directory?(@resource.name)

        if uptodate?
          Wright.log.debug "file already created: '#{@resource.name}'"
          return
        end

        create_file
        @updated = true
      end

      # Public: Remove the File.
      #
      # Returns nothing.
      def remove!
        file = @resource.name

        fail Errno::EISDIR, file if ::File.directory?(file)

        if ::File.exist?(file) || ::File.symlink?(file)
          remove_file
          @updated = true
        else
          Wright.log.debug "file already removed: '#{file}'"
        end
      end

      private

      def create_file
        file_permissions = permissions

        if Wright.dry_run?
          Wright.log.info "(would) create file: '#{@resource.name}'"
        else
          Wright.log.info "create file: '#{@resource.name}'"
          write_content_to_file
          file_permissions.update
        end
      end

      def write_content_to_file
        file = Tempfile.new(::File.basename(@resource.name))
        file.write(@resource.content) if @resource.content
        file.close
        if @resource.content || !::File.exist?(@resource.name)
          FileUtils.mv(file.path, @resource.name)
        else
          file.unlink
        end
      end

      def remove_file
        file = @resource.name
        if Wright.dry_run?
          Wright.log.info "(would) remove file: '#{file}'"
        else
          Wright.log.info "remove file: '#{file}'"
          FileUtils.rm(file)
        end
      end

      def permissions
        Wright::Util::FilePermissions.create_from_resource(@resource, :file)
      end

      def checksum(content)
        Digest::SHA256.hexdigest(content)
      end

      def content_uptodate?
        return false unless ::File.exist?(@resource.name)
        content = @resource.content || ''
        target_checksum = checksum(content)
        current_checksum = checksum(::File.read(@resource.name))
        current_checksum == target_checksum
      end

      def uptodate?
        content_uptodate? && permissions.uptodate?
      end
    end
  end
end
