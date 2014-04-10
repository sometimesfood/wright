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
      attr_reader :owner

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

      def update
        # Util::User.group_to_gid(group) unless group.nil?
        # Util::User.user_to_uid(owner)
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
