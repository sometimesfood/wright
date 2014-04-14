module Wright
  module Util
    # Internal: Various file methods.
    module File
      def self.user_mask(target)
        mask = 0
        target.each_byte do |byte_chr|
          case byte_chr.chr
          when 'u'
            mask |= 04700
          when 'g'
            mask |= 02070
          when 'o'
            mask |= 01007
          when 'a'
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
          when 'r'
            mask |= 0444
          when 'w'
            mask |= 0222
          when 'x'
            mask |= 0111
          when 'X'
            mask |= 0111 if is_directory
          when 's'
            mask |= 06000
          when 't'
            mask |= 01000
          end
        end
        mask
      end
      private_class_method :mode_mask

      def self.symbolic_modes_to_i(modes, current_mode, filetype = :file)
        is_directory = (filetype == :directory)
        unless symbolic_mode?(modes)
          fail ArgumentError, "Invalid file mode \"#{modes}\""
        end
        modes.split(/,/).reduce(0) do |mode, mode_sym|
          mode_sym = "a#{mode_sym}" if mode_sym =~ /\A[+-=]/
          target, mode = mode_sym.split(/[+-=]/)
          user_mask = user_mask(target)
          mode_mask = mode_mask(mode ? mode : '', is_directory)

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

      def self.numeric_mode_to_i(mode)
        return mode.to_i unless mode.is_a?(String)
        mode =~ /\A[0-7]{3,4}\Z/ ? mode.to_i(8) : nil
      end

      def self.symbolic_mode?(mode_str)
        return true if mode_str.empty?
        mode_fragment = /([augo]*[+-=][rwxXst]*)/
        mode_re = /\A#{mode_fragment}(,#{mode_fragment})*\Z/
        !(mode_str =~ mode_re).nil?
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
    end
  end
end
