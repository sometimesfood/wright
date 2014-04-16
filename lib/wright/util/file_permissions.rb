require 'wright/util/file'
require 'wright/util/user'

module Wright
  module Util
    class FilePermissions
      def self.create_from_resource(resource, filetype)
        p = Wright::Util::FilePermissions.new(resource.name, filetype)
        p.owner = resource.owner
        p.group = resource.group
        p.mode = resource.mode
        p
      end

      attr_accessor :filename, :group, :mode
      attr_reader :owner

      VALID_FILETYPES = [:file, :directory]

      def initialize(filename, filetype)
        unless VALID_FILETYPES.include?(filetype)
          fail ArgumentError, "Invalid filetype '#{filetype}'"
        end
        @filename = filename
        @filetype = filetype
      end

      def owner=(owner)
        @owner = Util::User.user_to_uid(owner)
      end

      def group=(group)
        @group = Util::User.group_to_gid(group)
      end

      def mode=(mode)
        if mode.nil?
          @mode = nil
          return
        end

        mode_i = File.numeric_mode_to_i(mode)
        unless mode_i
          base_mode_i = ::File.exist?(@filename) ? current_mode : default_mode
          mode_i = File.symbolic_modes_to_i(mode, base_mode_i, @filetype)
        end
        @mode = mode_i
      end

      def uptodate?
        if ::File.exist?(@filename)
          owner_uptodate? && group_uptodate? && mode_uptodate?
        else
          false
        end
      end

      def update
        ::File.chmod(@mode, @filename) if @mode
        ::File.chown(@owner, @group, @filename) if @owner || @group
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
