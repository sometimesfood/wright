require 'wright/provider'
require 'fileutils'

module Wright
  class Provider
    # Public: Symlink provider. Used as a Provider for Resource::Symlink.
    class Symlink < Wright::Provider
      # Public: Create or update the Symlink.
      #
      # Returns nothing.
      def create
        if exist?
          symlink = symlink_to_s(@resource.name, @resource.to)
          Wright.log.debug "symlink already created: #{symlink}"
          return
        end

        fail Errno::EEXIST, @resource.name if regular_file?
        create_link
        @updated = true
      end

      # Public: Remove the Symlink.
      #
      # Returns nothing.
      def remove
        if ::File.exist?(@resource.name) && !::File.symlink?(@resource.name)
          fail "'#{@resource.name}' is not a symlink"
        end

        if ::File.symlink?(@resource.name)
          remove_symlink
          @updated = true
        else
          Wright.log.debug "symlink already removed: '#{@resource.name}'"
        end
      end

      private

      # Internal: Checks if the specified link exists.
      #
      # Returns true if the link exists and points to the specified target
      # and false otherwise.
      def exist? #:doc:
        ::File.symlink?(@resource.name) &&
          ::File.readlink(@resource.name) == @resource.to
      end

      def create_link
        symlink = symlink_to_s(@resource.name, @resource.to)
        if Wright.dry_run?
          Wright.log.info "(would) create symlink: #{symlink}"
        else
          Wright.log.info "create symlink: #{symlink}"
          Wright::Util::File.ln_sfn(@resource.to, @resource.name)
        end
      end

      def symlink_to_s(link_name, target)
        "'#{link_name}' -> '#{target}'"
      end

      def remove_symlink
        if Wright.dry_run?
          Wright.log.info "(would) remove symlink: '#{@resource.name}'"
        else
          Wright.log.info "remove symlink: '#{@resource.name}'"
          FileUtils.rm(@resource.name)
        end
      end

      def regular_file?
        ::File.exist?(@resource.name) && !::File.symlink?(@resource.name)
      end
    end
  end
end
