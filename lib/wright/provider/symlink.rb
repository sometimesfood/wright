require 'wright/provider'
require 'wright/util/file'
require 'fileutils'

module Wright
  class Provider
    # Symlink provider. Used as a provider for {Resource::Symlink}.
    class Symlink < Wright::Provider
      # Creates or updates the symlink.
      #
      # @return [void]
      def create
        if exist?
          symlink = symlink_to_s(@resource.name, @resource.to)
          Wright.log.debug "symlink already created: #{symlink}"
          return
        end

        fail Errno::EEXIST, link_name if regular_file?
        create_link
        @updated = true
      end

      # Removes the symlink.
      #
      # @return [void]
      def remove
        if ::File.exist?(link_name) && !::File.symlink?(link_name)
          fail "'#{link_name}' is not a symlink"
        end

        if ::File.symlink?(link_name)
          remove_symlink
          @updated = true
        else
          Wright.log.debug "symlink already removed: '#{@resource.name}'"
        end
      end

      private

      # Checks if the specified link exists.
      #
      # Returns true if the link exists and points to the specified
      # target and false otherwise.
      def exist?
        ::File.symlink?(link_name) &&
          ::File.readlink(link_name) == link_to
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
        Wright::Util::File.expand_tilde_path(@resource.to)
      end

      def link_name
        Wright::Util::File.expand_tilde_path(@resource.name)
      end
    end
  end
end
