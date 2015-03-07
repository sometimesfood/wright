require 'etc'
require 'wright/provider'

module Wright
  class Provider
    # Package provider. Used as a base class for Resource::Package
    # providers.
    class Group < Wright::Provider
      # Adds the group.
      #
      # @return [void]
      def create
        if uptodate?(:create)
          Wright.log.debug "group already created: '#{@resource.name}'"
          return
        end

        create_group
        @updated = true
      end

      # Removes the group.
      #
      # @return [void]
      def remove
        if uptodate?(:remove)
          Wright.log.debug "group already removed: '#{@resource.name}'"
          return
        end

        remove_group
        @updated = true
      end

      private

      # @api public
      # Checks if the group is up-to-date for a given action.
      #
      # @param action [Symbol] the action. Currently supports
      #   +:create+ and +:remove+.
      #
      # @return [Bool] +true+ if the group is up-to-date and +false+
      #   otherwise
      # @raise [ArgumentError] if the action is invalid
      def uptodate?(action)
        case action
        when :create
          group_exists? && gid_uptodate? && members_uptodate?
        when :remove
          !group_exists?
        else
          fail ArgumentError, "invalid action '#{action}'"
        end
      end

      def create_group
        group = @resource.name
        unless_dry_run("create group: '#{group}'") do
          if group_exists?
            set_gid(group, @resource.gid) unless gid_uptodate?
          else
            add_group(group, @resource.gid, @resource.system)
          end
          set_members(group, @resource.members) unless members_uptodate?
        end
      end

      def remove_group
        group = @resource.name
        unless_dry_run("remove group: '#{group}'") do
          delete_group(group)
        end
      end

      def group_data
        Etc.getgrnam(@resource.name)
      rescue ArgumentError
        nil
      end

      def gid_uptodate?
        @resource.gid.nil? ? true : (group_data.gid == @resource.gid)
      end

      def members_uptodate?
        @resource.members.nil? ? true : (group_data.mem == @resource.members)
      end

      def group_exists?
        !group_data.nil?
      end

      def set_members
        group = @resource.name
        new_members = @resource.members - group_data.mem
        unwanted_members = group_data.mem - @resource.members
        new_members.each { |m| add_member(m, group) }
        unwanted_members.each { |m| remove_member(m, group) }
      end

      def add_member(_member, _group)
        fail NotImplementedError
      end

      def remove_member(_member, _group)
        fail NotImplementedError
      end
    end
  end
end
