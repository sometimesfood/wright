module Wright
  module Util

    # Internal: Various file methods.
    module File
      def self.user_mask(target)
        mask = 0
        target.each_byte do |byte_chr|
          case byte_chr.chr
          when "u"
            mask |= 04700
          when "g"
            mask |= 02070
          when "o"
            mask |= 01007
          when "a"
            mask |= 07777
          end
        end
        mask
      end
      private_class_method :user_mask

      def self.mode_mask(mode, is_directory)
        mask = 0
        mode.each_byte do |byte_chr|
          case byte_chr.chr
          when "r"
            mask |= 0444
          when "w"
            mask |= 0222
          when "x"
            mask |= 0111
          when "X"
            mask |= 0111 if is_directory
          when "s"
            mask |= 06000
          when "t"
            mask |= 01000
          end
        end
        mask
      end
      private_class_method :mode_mask

      def self.symbolic_modes_to_i(modes, current_mode, is_directory)
        unless symbolic_mode?(modes)
          raise ArgumentError, "Invalid file mode \"#{modes}\""
        end
        modes.split(/,/).inject(0) do |mode, mode_sym|
          mode_sym = "a#{mode_sym}" if mode_sym =~ %r!^[+-=]!
          target, mode = mode_sym.split %r![+-=]!
          user_mask = user_mask(target)
          mode_mask = mode_mask(mode ? mode : "", is_directory)

          case mode_sym
          when /=/
            current_mode &= ~(user_mask)
            current_mode |= user_mask & mode_mask
          when /\+/
            current_mode |= user_mask & mode_mask
          when /-/
            current_mode &= ~(user_mask & mode_mask)
          end
        end
      end
      private_class_method :symbolic_modes_to_i

      def self.numeric_mode_to_i(mode)
        return mode.to_i unless mode.is_a?(String)
        mode =~ /\A[0-7]{3,4}\Z/ ? mode.to_i(8) : nil
      end
      private_class_method :numeric_mode_to_i

      def self.symbolic_mode?(mode_str)
        return true if mode_str.empty?
        mode_fragment = /([augo]*[+-=][rwxXst]*)/
        mode_re = /\A#{mode_fragment}(,#{mode_fragment})*\Z/
        !!(mode_str =~ mode_re)
      end
      private_class_method :symbolic_mode?

      # Internal: Get a file's current mode.
      #
      # path - The file's path.
      #
      # Examples
      #
      #   FileUtils.touch('foo')
      #   FileUtils.chmod(0644, 'foo')
      #   Wright::Util::File.file_mode('foo').to_s(8)
      #   # => "644"
      #
      # Returns the file mode as an integer.
      def self.file_mode(path)
        ::File.stat(path).mode & 07777
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
      def self.file_mode_to_i(mode, path = '')
        mode_i = numeric_mode_to_i(mode)
        unless mode_i
          current_mode = if ::File.exist?(path)
                           file_mode(path)
                         else
                           (~::File.umask & 0666)
                         end
          mode_i = symbolic_modes_to_i(mode, current_mode, false)
        end
        mode_i
      end

      # Internal: Convert directory access modes to integer modes.
      #
      # mode - The mode to convert. Symbolic mode String, integer in a
      #        String or integer mode.
      #
      # path - The directory's path. Only used for relative modes
      #        (eg. 'a+x', 'u=rw' etc.). If the directory at the given
      #        path does not exist, the current umask is used to
      #        determine the base mode.
      #
      # Examples
      #
      #   Wright::Util::File.dir_mode_to_i(0644).to_s(8)
      #   # => "644"
      #
      #   Wright::Util::File.dir_mode_to_i('644').to_s(8)
      #   # => "644"
      #
      #   FileUtils.touch('foo')
      #   FileUtils.chmod(0444, 'foo')
      #   Wright::Util::File.file_mode_to_i('u=wr,go+X', 'foo').to_s(8)
      #   # => "644"
      #
      #   File.umask(000)
      #   Wright::Util::File.file_mode_to_i('go-w').to_s(8)
      #   # => "644"
      #
      # Returns the file mode as an integer.
      # Raises ArgumentError if mode is an invalid symbolic mode.
      def self.dir_mode_to_i(mode, path = '')
        mode_i = numeric_mode_to_i(mode)
        unless mode_i
          current_mode = if ::File.exist?(path) && ::File.directory?(path)
                           file_mode(path)
                         else
                           (~::File.umask & 0777)
                         end
          mode_i = symbolic_modes_to_i(mode, current_mode, true)
        end
        mode_i
      end
    end
  end
end
