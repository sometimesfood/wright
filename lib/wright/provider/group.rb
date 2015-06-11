require 'etc'
require 'wright/provider'

module Wright
  class Provider
    # Group provider. Used as a base class for {Resource::Group}
    # providers.
    class Group < Wright::Provider
      # Creates or updates the group.
      #
      # @return [void]
      def create
        unless_uptodate(:create, "group already created: '#{group_name}'") do
          unless_dry_run("create group: '#{group_name}'") do
            ensure_group_exists
            set_members unless members_uptodate?
          end
        end
      end

      # Removes the group.
      #
      # @return [void]
      def remove
        unless_uptodate(:remove, "group already removed: '#{group_name}'") do
          unless_dry_run("remove group: '#{group_name}'") do
            remove_group
          end
        end
      end

      private

      def group_name
        @resource.name
      end

      def gid
        @resource.gid
      end

      def members
        @resource.members
      end

      def system_group?
        @resource.system
      end

      def ensure_group_exists
        if group_exists?
          set_gid unless gid_uptodate?
        else
          create_group
        end
      end

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

      def group_data
        Wright::Util::User.safe_getgrnam(group_name)
      end

      def gid_uptodate?
        gid.nil? || group_data.gid == gid
      end

      def members_uptodate?
        members.nil? || group_data.mem == members
      end

      def group_exists?
        !group_data.nil?
      end

      def set_members
        new_members = members - group_data.mem
        unwanted_members = group_data.mem - members
        new_members.each { |m| add_member(m, group_name) }
        unwanted_members.each { |m| remove_member(m, group_name) }
      end

      def create_group
        fail NotImplementedError
      end

      def remove_group
        fail NotImplementedError
      end

      def set_gid
        fail NotImplementedError
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
