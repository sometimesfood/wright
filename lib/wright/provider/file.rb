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
      # @raise [Errno::EISDIR] if there is already a directory with
      #   the specified name
      def create
        fail_if_directory
        file = @resource.name
        unless_uptodate(:create, "file already created: '#{file}'") do
          create_file
        end
      end

      # Removes the file.
      #
      # @return [void]
      # @raise [Errno::EISDIR] if there is a directory with the
      #   specified name
      def remove
        fail_if_directory
        file = @resource.name
        unless_uptodate(:remove, "file already removed: '#{file}'") do
          remove_file
        end
      end

      private

      def create_file
        file_permissions = permissions
        unless_dry_run("create file: '#{@resource.name}'") do
          write_content_to_file
          file_permissions.update unless file_permissions.uptodate?
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
        target_checksum = checksum(content.to_s)
        current_checksum = checksum(::File.read(filename))
        current_checksum == target_checksum
      end

      def uptodate?(action)
        case action
        when :create
          content_uptodate? && permissions.uptodate?
        when :remove
          !::File.exist?(filename) && !::File.symlink?(filename)
        end
      end

      def filename
        ::File.expand_path(@resource.name)
      end

      def fail_if_directory
        fail Errno::EISDIR, filename if ::File.directory?(filename)
      end
    end
  end
end
