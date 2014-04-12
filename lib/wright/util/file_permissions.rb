require 'wright/util/file'
require 'wright/util/user'

module Wright
  module Util
    class FilePermissions
      VALID_FILETYPES = [:file, :directory]

      def initialize(filename, filetype)
        unless VALID_FILETYPES.include?(filetype)
          fail ArgumentError, "Invalid filetype '#{filetype}'"
        end
        @filename = filename
        @filetype = filetype
      end

      attr_accessor :group, :mode
      attr_reader :owner, :filename

      def owner=(owner)
        if owner.is_a?(String)
          if owner.count(':') > 1
            fail ArgumentError, "Invalid owner: '#{owner}'"
          end
          @owner, @group = owner.split(':')
        else
          @owner = owner
        end
      end

      def uptodate?
        if ::File.exist?(@filename)
          owner_uptodate? && mode_uptodate? # && group_uptodate?
        else
          false
        end
      end

      def update
        target_mode = mode_to_i
        ::File.chmod(target_mode, @filename) if target_mode

        # Util::User.group_to_gid(group) unless group.nil?
        target_owner = owner_to_i
        target_group = nil
        if target_owner || target_group
          ::File.chown(target_owner, target_group, @filename)
        end
      end

      def default_mode
        case @filetype
        when :file
          ~::File.umask & 0666
        when :directory
          ~::File.umask & 0777
        end
      end

      # Internal: Convert file access modes to integer modes.
      #
      # mode - The mode to convert. Symbolic mode String, integer in a
      #        String or integer mode.
      #
      # path - The file's path. Only used for relative modes
      #        (eg. 'a+x', 'u=rw' etc.). If the file at the given path
      #        does not exist, the current umask is used to determine
      #        the base mode.
      #
      # Examples
      #
      #   Wright::Util::File.dir_mode_to_i(0644).to_s(8)
      #   # => "644"
      #
      #   Wright::Util::File.dir_mode_to_i('644').to_s(8)
      #   # => "644"
      #
      #   FileUtils.mkdir_p('foo')
      #   FileUtils.chmod(0444, 'foo')
      #   Wright::Util::File.dir_mode_to_i('u=wr,go+X', 'foo').to_s(8)
      #   # => "655"
      #
      #   File.umask(000)
      #   Wright::Util::File.dir_mode_to_i('go-w').to_s(8)
      #   # => "755"
      #
      # Returns the file mode as an integer.
      # Raises ArgumentError if mode is an invalid symbolic mode.
      def mode_to_i
        return nil if @mode.nil?

        mode_i = Wright::Util::File.numeric_mode_to_i(@mode)
        unless mode_i
          current_mode_i =
            ::File.exist?(@filename) ? current_mode : default_mode
          mode_i = Wright::Util::File.symbolic_modes_to_i(@mode,
                                                          current_mode_i,
                                                          @filetype)
        end
        mode_i
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

      def owner_uptodate?
        target_owner = owner_to_i
        target_owner.nil? ? true : current_owner == target_owner
      end

      def group_uptodate?
      end

      def mode_uptodate?
        target_mode = mode_to_i
        target_mode.nil? ? true : current_mode == target_mode
      end
    end
  end
end
