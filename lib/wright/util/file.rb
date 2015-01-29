# The file mode conversion functions in this file are based on those
# of Ruby's FileUtils, more specifically some methods found in
# lib/fileutils.rb in MRI 2.1.1.
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
    # Various file methods.
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

      # Converts a symbolic mode string to an integer mode value.
      #
      # @param mode [String] the symbolic mode string
      # @param base_mode [Integer] the base mode
      # @param filetype [Symbol] the filetype
      #
      # @example
      #   Wright::Util::File.symbolic_mode_to_i('u=rw,go=r', 0400).to_s(8)
      #   # => "644"
      #
      #   Wright::Util::File.symbolic_mode_to_i('u=rw,g+r', 0200).to_s(8)
      #   # => "640"
      #
      # @return [Integer] the integer mode
      def self.symbolic_mode_to_i(mode, base_mode, filetype = :file)
        is_directory = (filetype == :directory)
        unless symbolic_mode?(mode)
          fail ArgumentError, "Invalid file mode \"#{mode}\""
        end
        mode_i = base_mode
        mode.split(/,/).each do |mode_clause|
          mode_i = mode_clause_to_i(mode_clause, mode_i, is_directory)
        end
        mode_i
      end

      # Converts a single symbolic mode clause to an integer mode
      # value.
      #
      # @param mode_clause [String] the symbolic mode clause
      # @param base_mode_i [Integer] the integer base mode
      # @param is_directory [Bool] denotes whether the mode_clause
      #   should be treated as a symbolic directory mode clause
      #
      # @example
      #   Wright::Util::File.mode_clause_to_i('g+r', 0600, false).to_s(8)
      #   # => "640"
      #
      #   Wright::Util::File.mode_clause_to_i('+rw', 0600, false).to_s(8)
      #   # => "666"
      #
      # @return [Integer] the mode clause as an integer
      def self.mode_clause_to_i(mode_clause, base_mode_i, is_directory)
        mode_clause = "a#{mode_clause}" if mode_clause =~ /\A[+-=]/
        who, op, perm = mode_clause.split(/([+-=])/)
        perm ||= ''
        user_mask = user_mask(who)
        mode_mask = mode_mask(perm, is_directory)
        apply_user_mode_masks(base_mode_i, user_mask, op, mode_mask)
      end
      private_class_method :mode_clause_to_i

      def self.apply_user_mode_masks(base_mode_i, user_mask, op, mode_mask)
        case op
        when '='
          (base_mode_i & ~user_mask) | (user_mask & mode_mask)
        when '+'
          base_mode_i | (user_mask & mode_mask)
        when '-'
          base_mode_i & ~(user_mask & mode_mask)
        end
      end
      private_class_method :apply_user_mode_masks

      # Converts a numeric mode string to an integer mode.
      #
      # @param mode [String, #to_i] the numeric mode string
      #
      # @example
      #   Wright::Util::File.numeric_mode_to_i('0600').to_s(8)
      #   # => "600"
      #
      #   Wright::Util::File.numeric_mode_to_i('644').to_s(8)
      #   # => "644"
      #
      #   Wright::Util::File.numeric_mode_to_i(0644).to_s(8)
      #   # => "644"
      #
      #   Wright::Util::File.numeric_mode_to_i('invalid_mode').to_s(8)
      #   # => nil
      #
      # @return [Integer] the mode in integer form or +nil+ if the
      #   mode could not be converted
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

      # Returns a file's current mode.
      #
      # @param path [String] the file's path
      #
      # @example
      #   FileUtils.touch('foo')
      #   FileUtils.chmod(0644, 'foo')
      #   Wright::Util::File.file_mode('foo').to_s(8)
      #   # => "644"
      #
      # @return [Integer] the file mode as an integer or +nil+ if the
      #   file does not exist
      def self.file_mode(path)
        ::File.exist?(path) ? (::File.stat(path).mode & 07777) : nil
      end

      # Returns a file's owner.
      #
      # @param path [String] the file's path
      #
      # @example
      #   FileUtils.touch('foo')
      #   FileUtils.chown(0, 0, 'foo')
      #   Wright::Util::File.file_owner('foo')
      #   # => 0
      #
      #   Wright::Util::File.file_owner('nonexistent')
      #   # => nil
      #
      # @return [Integer] the file owner's uid or +nil+ if the file
      #   does not exist
      def self.file_owner(path)
        ::File.exist?(path) ? ::File.stat(path).uid : nil
      end

      # Returns a file's owner.
      #
      # @param path [String] the file's path
      #
      # @example
      #   FileUtils.touch('foo')
      #   FileUtils.chown(0, 0, 'foo')
      #   Wright::Util::File.file_group('foo')
      #   # => 0
      #
      #   Wright::Util::File.file_group('nonexistent')
      #   # => nil
      #
      # @return [Integer] the file owner's uid or nil if the file does
      #   not exist.
      def self.file_group(path)
        ::File.exist?(path) ? ::File.stat(path).gid : nil
      end

      # Expands tilde symbols in file paths. Path elements other than
      # the first one are left alone.
      #
      # @param path [String] the file path
      #
      # @example
      #   Wright::Util::File.expand_tilde_path('~root/foo')
      #   # => "/root/foo"
      #
      #   Wright::Util::File.expand_tilde_path('~root/foo/..')
      #   # => "/root/foo/.."
      #
      #   Wright::Util::File.expand_tilde_path('../foo/bar')
      #   # => "../foo/bar"
      #
      # @return [String] the expanded path
      def self.expand_tilde_path(path)
        return path unless path.start_with?('~')

        first, *rest = path.split(::File::SEPARATOR)
        ::File.join(::File.expand_path(first), rest)
      end

      # Creates symlinks without descending into directories.
      #
      # If the file denoted by link_name is a symlink to a directory,
      # {ln_sfn} does not descend into it. Behaves similar to GNU
      # ln(1) or OpenBSD ln(1) when using +ln -sfn target link_name+.
      #
      # @param target [String] the link target
      # @param link_name [String] the link name
      #
      # @return [void]
      def self.ln_sfn(target, link_name)
        if ::File.symlink?(link_name) && ::File.directory?(link_name)
          FileUtils.rm(link_name)
        end
        FileUtils.ln_sf(target, link_name)
      end
    end
  end
end
