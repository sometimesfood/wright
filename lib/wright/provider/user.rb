require 'etc'
require 'wright/provider'
require 'wright/util/user'

module Wright
  class Provider
    # User provider. Used as a base class for {Resource::User}
    # providers.
    class User < Wright::Provider
      # Creates or updates the user.
      #
      # @return [void]
      def create
        unless_uptodate(:create, "user already created: '#{user_name}'") do
          unless_dry_run("create user: '#{user_name}'") do
            if user_exists?
              update_user
            else
              create_user
            end
          end
        end
      end

      # Removes the user.
      #
      # @return [void]
      def remove
        unless_uptodate(:remove, "user already removed: '#{user_name}'") do
          unless_dry_run("remove user: '#{user_name}'") do
            remove_user
          end
        end
      end

      private

      def user_name
        @resource.name
      end

      def uid
        @resource.uid
      end

      def primary_group
        @resource.primary_group
      end

      def full_name
        @resource.full_name
      end

      def groups
        @resource.groups
      end

      def shell
        @resource.shell
      end

      def home
        @resource.home
      end

      def system_user?
        @resource.system
      end

      # @api public
      # Checks if the user is up-to-date for a given action.
      #
      # @param action [Symbol] the action. Currently supports
      #   +:create+ and +:remove+.
      #
      # @return [Bool] +true+ if the user is up-to-date and +false+
      #   otherwise
      # @raise [ArgumentError] if the action is invalid
      def uptodate?(action)
        case action
        when :create
          user_exists? && attributes_uptodate?
        when :remove
          !user_exists?
        else
          fail ArgumentError, "invalid action '#{action}'"
        end
      end

      def attributes_uptodate?
        uid_uptodate? &&
          full_name_uptodate? &&
          groups_uptodate? &&
          shell_uptodate? &&
          home_uptodate? &&
          primary_group_uptodate?
      end

      def user_data
        Wright::Util::User.safe_getpwnam(user_name)
      end

      def uid_uptodate?
        uid.nil? || user_data.uid == uid
      end

      def full_name_uptodate?
        full_name.nil? || user_data.gecos.split(',').first == full_name
      end

      def groups_uptodate?
        return true if groups.nil?
        target_groups = []
        Etc.group { |g| target_groups << g.name if g.mem.include?(user_name) }
        target_groups.sort.uniq == groups.sort.uniq
      end

      def shell_uptodate?
        shell.nil? || user_data.shell == shell
      end

      def home_uptodate?
        home.nil? || user_data.dir == home
      end

      def primary_group_uptodate?
        return true if primary_group.nil?
        user_data.gid == Wright::Util::User.group_to_gid(primary_group)
      end

      def user_exists?
        !user_data.nil?
      end

      def create_user
        fail NotImplementedError
      end

      def update_user
        fail NotImplementedError
      end

      def remove_user
        fail NotImplementedError
      end
    end
  end
end
