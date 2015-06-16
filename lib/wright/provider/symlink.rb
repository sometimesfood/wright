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
        fail Errno::EEXIST, link_name_expanded if regular_file?

        symlink = symlink_to_s
        unless_uptodate(:create, "symlink already created: #{symlink}") do
          unless_dry_run("create symlink: #{symlink}") do
            Wright::Util::File.ln_sfn(link_to_expanded, link_name_expanded)
          end
        end
      end

      # Removes the symlink.
      #
      # @return [void]
      def remove
        fail "'#{link_name_expanded}' is not a symlink" if regular_file?

        unless_uptodate(:remove, "symlink already removed: '#{link_name}'") do
          unless_dry_run("remove symlink: '#{link_name}'") do
            FileUtils.rm(link_name_expanded)
          end
        end
      end

      private

      def link_name
        resource.name
      end

      def link_to
        resource.to
      end

      def link_to_expanded
        return nil if link_to.nil?
        Wright::Util::File.expand_tilde_path(link_to)
      end

      def link_name_expanded
        Wright::Util::File.expand_tilde_path(link_name)
      end

      def symlink_to_s
        "'#{link_name}' -> '#{link_to}'"
      end

      def uptodate?(action)
        case action
        when :create
          ::File.symlink?(link_name_expanded) &&
            ::File.readlink(link_name_expanded) == link_to_expanded
        when :remove
          !::File.symlink?(link_name_expanded)
        end
      end

      def regular_file?
        ::File.exist?(link_name_expanded) &&
          !::File.symlink?(link_name_expanded)
      end
    end
  end
end
