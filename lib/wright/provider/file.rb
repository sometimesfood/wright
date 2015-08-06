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
      # @raise [Errno::EISDIR] if there already is a directory with
      #   the specified name
      def create
        fail_if_directory
        file_permissions = permissions
        unless_uptodate(:create, "file already created: '#{file_name}'") do
          unless_dry_run("create file: '#{file_name}'") do
            write_content_to_file
            file_permissions.update unless file_permissions.uptodate?
          end
        end
      end

      # Removes the file.
      #
      # @return [void]
      # @raise [Errno::EISDIR] if there is a directory with the
      #   specified name
      def remove
        fail_if_directory
        unless_uptodate(:remove, "file already removed: '#{file_name}'") do
          unless_dry_run("remove file: '#{file_name}'") do
            FileUtils.rm(filename_expanded)
          end
        end
      end

      private

      def file_name
        resource.name
      end

      def content
        resource.content
      end

      def permissions
        Wright::Util::FilePermissions.create_from_resource(resource, :file)
      end

      def write_content_to_file
        tempfile = Tempfile.new(::File.basename(filename_expanded))
        tempfile.write(content) if content
        move_tempfile(tempfile)
      ensure
        tempfile.close!
      end

      def move_tempfile(tempfile)
        # do not overwrite existing files if content was not specified
        return if content.nil? && ::File.exist?(filename_expanded)
        FileUtils.mv(tempfile.path, filename_expanded)
      end

      def checksum(content)
        Digest::SHA256.hexdigest(content)
      end

      def content_uptodate?
        return false unless ::File.exist?(filename_expanded)
        return true unless content
        target_content = content || ''
        target_checksum = checksum(target_content.to_s)
        current_checksum = checksum(::File.read(filename_expanded))
        current_checksum == target_checksum
      end

      def uptodate?(action)
        case action
        when :create
          content_uptodate? && permissions.uptodate?
        when :remove
          !::File.exist?(filename_expanded) &&
            !::File.symlink?(filename_expanded)
        end
      end

      def filename_expanded
        ::File.expand_path(file_name)
      end

      def fail_if_directory
        return unless ::File.directory?(filename_expanded)
        fail Errno::EISDIR, filename_expanded
      end
    end
  end
end
