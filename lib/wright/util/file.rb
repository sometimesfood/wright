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

      def self.symbolic_modes_to_i(modes, current_mode, filetype = :file)
        is_directory = (filetype == :directory)
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
      # private_class_method :symbolic_modes_to_i

      def self.numeric_mode_to_i(mode)
        return mode.to_i unless mode.is_a?(String)
        mode =~ /\A[0-7]{3,4}\Z/ ? mode.to_i(8) : nil
      end
      # private_class_method :numeric_mode_to_i

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
      # Returns the file mode as an integer or nil if the file does
      # not exist.
      def self.file_mode(path)
        ::File.exist?(path) ? (::File.stat(path).mode & 07777) : nil
      end

      # Internal: Get a file's owner.
      #
      # path - The file's path.
      #
      # Examples
      #
      #   FileUtils.touch('foo')
      #   FileUtils.chown(0, 0, 'foo')
      #   Wright::Util::File.file_owner('foo')
      #   # => 0
      #
      #   Wright::Util::File.file_owner('nonexistent')
      #   # => nil
      #
      # Returns the file owner's uid or nil if the file does not
      # exist.
      def self.file_owner(path)
        ::File.exist?(path) ? ::File.stat(path).uid : nil
      end

      # Internal: Get a file's owner.
      #
      # path - The file's path.
      #
      # Examples
      #
      #   FileUtils.touch('foo')
      #   FileUtils.chown(0, 0, 'foo')
      #   Wright::Util::File.file_group('foo')
      #   # => 0
      #
      #   Wright::Util::File.file_group('nonexistent')
      #   # => nil
      #
      # Returns the file owner's uid or nil if the file does not
      # exist.
      def self.file_group(path)
        ::File.exist?(path) ? ::File.stat(path).gid : nil
      end

      # TODO: remove this method

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

      def self.mode_uptodate?(filename, target_mode)
        return true unless target_mode
        target_mode_i = Util::File.file_mode_to_i(target_mode, filename)
        current_mode_i = Util::File.file_mode(filename)
        current_mode_i == target_mode_i
      end

      def self.owner_uptodate?(filename, target_owner)
        return true unless target_owner
        target_owner_i = Util::User.user_to_uid(target_owner)
        current_owner_i = Util::File.file_owner(filename)
        current_owner_i == target_owner_i
      end

      def self.group_uptodate?(filename, target_group)
        return true unless target_group
        target_group_i = Util::User.group_to_gid(target_group)
        current_group_i = Util::File.file_group(filename)
        current_group_i == target_group_i
      end
    end
  end
end
