require 'wright/util/file'
require 'wright/util/user'

module Wright
  module Util
    # Internal: Helper class to manage file permissions.
    class FilePermissions
      # Internal: Create a FilePermissions from a Wright::Resource.
      #
      # resource - The resource object.
      # filetype - The file's type, typically :file or :directory.
      #
      # Returns a Wright::Util::FilePermissions object.
      def self.create_from_resource(resource, filetype)
        filepath = ::File.expand_path(resource.name)
        p = Wright::Util::FilePermissions.new(filepath, filetype)
        p.owner = resource.owner
        p.group = resource.group
        p.mode = resource.mode
        p
      end

      # Internal: Get/Set the target file's name.
      attr_accessor :filename

      # Internal: Get/Set the file's target group.
      attr_accessor :group

      # Internal: Get/Set the file's target mode.
      attr_accessor :mode

      # Internal: Get the file's target owner.
      attr_reader :owner

      # Internal: Supported filetypes.
      VALID_FILETYPES = [:file, :directory]

      # Internal: Initialize a FilePermissions object.
      #
      # filename - The file's name.
      # filetype - The file's type, typically :file or :directory.
      def initialize(filename, filetype)
        unless VALID_FILETYPES.include?(filetype)
          fail ArgumentError, "Invalid filetype '#{filetype}'"
        end
        @filename = filename
        @filetype = filetype
      end

      # Internal: Set the file's owner.
      def owner=(owner)
        @owner = Util::User.user_to_uid(owner)
      end

      # Internal: Set the file's group
      def group=(group)
        @group = Util::User.group_to_gid(group)
      end

      # Internal: Set the file's mode.
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

      # Internal: Check if the file's owner, group and mode are up-to-date.
      def uptodate?
        if ::File.exist?(@filename)
          owner_uptodate? && group_uptodate? && mode_uptodate?
        else
          false
        end
      end

      # Internal: Update the file's owner, group and mode.
      def update
        ::File.chmod(@mode, @filename) if @mode
        ::File.chown(@owner, @group, @filename) if @owner || @group
      end

      # Internal: Get the file's current mode.
      def current_mode
        Wright::Util::File.file_mode(@filename)
      end

      # Internal: Get the file's current owner.
      def current_owner
        Wright::Util::File.file_owner(@filename)
      end

      # Internal: Get the file's current group.
      def current_group
        Wright::Util::File.file_group(@filename)
      end

      private

      def owner_uptodate?
        @owner.nil? || current_owner == @owner
      end

      def group_uptodate?
        @group.nil? || current_group == @group
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
