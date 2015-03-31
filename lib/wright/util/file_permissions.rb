require 'wright/util/file'
require 'wright/util/user'

module Wright
  module Util
    # Helper class to manage file permissions.
    class FilePermissions
      # Creates a FilePermissions object from a
      # {Wright::Resource::File} or {Wright::Resource::Directory}.
      #
      # @param resource [Wright::Resource::File,
      #   Wright::Resource::Directory] the resource object
      # @param filetype [Symbol] the file's type (+:file+ or +:directory+)
      #
      # @return [Wright::Util::FilePermissions] the FilePermissions
      #   object
      # @raise [ArgumentError] if the user or group are invalid
      def self.create_from_resource(resource, filetype)
        filepath = ::File.expand_path(resource.name)
        p = Wright::Util::FilePermissions.new(filepath, filetype)
        p.uid = Wright::Util::User.user_to_uid(resource.owner)
        p.gid = Wright::Util::User.group_to_gid(resource.group)
        p.mode = resource.mode
        p
      end

      # @return [String] the filename
      attr_accessor :filename

      # @return [Integer] the file's intended uid
      attr_accessor :uid

      # @return [Integer] the file's intended gid
      attr_accessor :gid

      # @return [Integer] the file's intended mode
      attr_reader :mode

      VALID_FILETYPES = [:file, :directory]
      private_constant :VALID_FILETYPES

      # Initializes a FilePermissions object.
      #
      # @param filename [String] the file's name
      # @param filetype [Symbol] the file's type (+:file+ or +:directory+)
      def initialize(filename, filetype)
        unless VALID_FILETYPES.include?(filetype)
          fail ArgumentError, "Invalid filetype '#{filetype}'"
        end
        @filename = filename
        @filetype = filetype
      end

      # @return [Integer] the file's target mode
      def mode=(mode)
        if mode.nil?
          @mode = nil
          return
        end

        mode_i = File.numeric_mode_to_i(mode)
        unless mode_i
          base_mode_i = ::File.exist?(@filename) ? current_mode : default_mode
          mode_i = File.symbolic_mode_to_i(mode, base_mode_i, @filetype)
        end
        @mode = mode_i
      end

      # Checks if the file's uid, gid and mode are up-to-date
      # @return [Bool] +true+ if the file is up to date, +false+
      #   otherwise
      def uptodate?
        if ::File.exist?(@filename)
          uid_uptodate? && gid_uptodate? && mode_uptodate?
        else
          false
        end
      end

      # Updates the file's uid, gid and mode.
      #
      # @return [void]
      def update
        ::File.chmod(@mode, @filename) if @mode
        ::File.chown(@uid, @gid, @filename) if @uid || @gid
      end

      # @return [Integer] the file's current mode
      def current_mode
        Wright::Util::File.file_mode(@filename)
      end

      # @return [Integer] the file's current owner's uid
      def current_uid
        Wright::Util::File.file_owner(@filename)
      end

      # @return [Integer] the file's current group's gid
      def current_gid
        Wright::Util::File.file_group(@filename)
      end

      private

      def uid_uptodate?
        @uid.nil? || current_uid == @uid
      end

      def gid_uptodate?
        @gid.nil? || current_gid == @gid
      end

      def mode_uptodate?
        @mode.nil? || current_mode == @mode
      end

      def default_mode
        case @filetype
        when :file
          ~::File.umask & 0666
        when :directory
          ~::File.umask & 0777
        end
      end
    end
  end
end
