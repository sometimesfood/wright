require 'fileutils'
require 'wright/provider'
require 'wright/util/file'

module Wright
  class Provider
    # Symlink provider. Used as a provider for {Resource::Symlink}.
    class Symlink < Wright::Provider
      # Creates or updates the symlink.
      #
      # @return [void]
      def create
        fail Errno::EEXIST, link_name if regular_file?

        symlink = symlink_to_s(@resource.name, @resource.to)
        unless_uptodate(:create, "symlink already created: #{symlink}") do
          create_link
        end
      end

      # Removes the symlink.
      #
      # @return [void]
      def remove
        fail "'#{link_name}' is not a symlink" if regular_file?

        symlink = @resource.name
        unless_uptodate(:remove, "symlink already removed: '#{symlink}'") do
          remove_symlink
        end
      end

      private

      def uptodate?(action)
        case action
        when :create
          ::File.symlink?(link_name) &&
            ::File.readlink(link_name) == link_to
        when :remove
          !::File.symlink?(link_name)
        end
      end

      def create_link
        symlink = symlink_to_s(@resource.name, @resource.to)
        unless_dry_run("create symlink: #{symlink}") do
          Wright::Util::File.ln_sfn(link_to, link_name)
        end
      end

      def symlink_to_s(link_name, target)
        "'#{link_name}' -> '#{target}'"
      end

      def remove_symlink
        unless_dry_run("remove symlink: '#{@resource.name}'") do
          FileUtils.rm(link_name)
        end
      end

      def regular_file?
        ::File.exist?(link_name) && !::File.symlink?(link_name)
      end

      def link_to
        return nil if @resource.to.nil?
        Wright::Util::File.expand_tilde_path(@resource.to)
      end

      def link_name
        Wright::Util::File.expand_tilde_path(@resource.name)
      end
    end
  end
end
