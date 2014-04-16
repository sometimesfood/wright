# Most functions in this file are based on Ruby's FileUtils, more
# specifically lib/fileutils.rb in Ruby 2.1.1.
#
# The following is a verbatim copy of the original license:
#
#   Copyright (C) 1993-2013 Yukihiro Matsumoto. All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
#   1. Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#   2. Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
#   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
#   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
#   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.

module Wright
  module Util
    # Internal: Various file methods.
    module File
      USER_MAP = {
        'u' => 04700,
        'g' => 02070,
        'o' => 01007,
        'a' => 07777
      }
      private_constant :USER_MAP

      def self.user_mask(target)
        target.chars.reduce(0) { |a, e| a | USER_MAP[e] }
      end
      private_class_method :user_mask

      MODE_MAP = {
        'r' => 0444,
        'w' => 0222,
        'x' => 0111,
        's' => 06000,
        't' => 01000
      }
      private_constant :MODE_MAP

      def self.mode_mask(mode, is_directory)
        mode.gsub!('X', 'x') if is_directory
        mode.chars.reduce(0) { |a, e| a | MODE_MAP[e].to_i }
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
