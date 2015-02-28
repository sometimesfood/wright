require 'fileutils'
require 'digest'
require 'tempfile'
require 'tmpdir'
require 'wright/provider'
require 'wright/util/file_permissions'
require 'wright/util/user'

module Wright
  class Provider
    # File provider. Used as a provider for {Resource::File}.
    class File < Wright::Provider
      # Creates or updates the file.
      #
      # @return [void]
      def create
        fail Errno::EISDIR, filename if ::File.directory?(filename)

        if uptodate?
          Wright.log.debug "file already created: '#{@resource.name}'"
          return
        end

        create_file
        @updated = true
      end

      # Removes the file.
      #
      # @return [void]
      def remove
        fail Errno::EISDIR, filename if ::File.directory?(filename)

        if ::File.exist?(filename) || ::File.symlink?(filename)
          remove_file
          @updated = true
        else
          Wright.log.debug "file already removed: '#{@resource.name}'"
        end
      end

      private

      def create_file
        file_permissions = permissions
        unless_dry_run("create file: '#{@resource.name}'") do
          write_content_to_file
          file_permissions.update
        end
      end

      def write_content_to_file
        tempfile = Tempfile.new(::File.basename(filename))
        tempfile.write(@resource.content) if @resource.content
        move_tempfile(tempfile)
      ensure
        tempfile.close!
      end

      def move_tempfile(tempfile)
        # do not overwrite existing files if content was not specified
        return if @resource.content.nil? && ::File.exist?(filename)
        FileUtils.mv(tempfile.path, filename)
      end

      def remove_file
        unless_dry_run("remove file: '#{@resource.name}'") do
          FileUtils.rm(filename)
        end
      end

      def permissions
        Wright::Util::FilePermissions.create_from_resource(@resource, :file)
      end

      def checksum(content)
        Digest::SHA256.hexdigest(content)
      end

      def content_uptodate?
        return false unless ::File.exist?(filename)
        content = @resource.content || ''
        target_checksum = checksum(content)
        current_checksum = checksum(::File.read(filename))
        current_checksum == target_checksum
      end

      def uptodate?
        content_uptodate? && permissions.uptodate?
      end

      def filename
        ::File.expand_path(@resource.name)
      end
    end
  end
end
