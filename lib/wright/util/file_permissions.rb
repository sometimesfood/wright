require 'wright/util/file'
require 'wright/util/user'

module Wright
  module Util
    class FilePermissions
      attr_accessor :filename, :owner, :group, :mode

      VALID_FILETYPES = [:file, :directory]

      def initialize(filename, filetype)
        unless VALID_FILETYPES.include?(filetype)
          fail ArgumentError, "Invalid filetype '#{filetype}'"
        end
        @filename = filename
        @filetype = filetype
      end

      def uptodate?
        if ::File.exist?(@filename)
          owner_uptodate? && group_uptodate? && mode_uptodate?
        else
          false
        end
      end

      def update
        target_mode = mode_to_i
        ::File.chmod(target_mode, @filename) if target_mode

        target_owner = owner_to_i
        target_group = group_to_i
        if target_owner || target_group
          ::File.chown(target_owner, target_group, @filename)
        end
      end

      def current_mode
        Wright::Util::File.file_mode(@filename)
      end

      def current_owner
        Wright::Util::File.file_owner(@filename)
      end

      def current_group
        Wright::Util::File.file_group(@filename)
      end

      private

      def owner_to_i
        Util::User.user_to_uid(@owner)
      end

      def group_to_i
        Util::User.group_to_gid(@group)
      end

      # Internal: Convert file access mode to integer mode.
      #
      # Returns the file mode as an integer.
      # Raises ArgumentError if mode is an invalid symbolic mode.
      def mode_to_i
        return nil if @mode.nil?

        mode_i = File.numeric_mode_to_i(@mode)
        unless mode_i
          current_mode_i =
            ::File.exist?(@filename) ? current_mode : default_mode
          mode_i = File.symbolic_modes_to_i(@mode, current_mode_i, @filetype)
        end
        mode_i
      end

      def owner_uptodate?
        target_owner = owner_to_i
        target_owner.nil? ? true : current_owner == target_owner
      end

      def group_uptodate?
        target_group = group_to_i
        target_group.nil? ? true : current_group == target_group
      end

      def mode_uptodate?
        target_mode = mode_to_i
        target_mode.nil? ? true : current_mode == target_mode
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
