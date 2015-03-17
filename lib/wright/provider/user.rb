require 'etc'
require 'wright/provider'
require 'wright/util/user'

module Wright
  class Provider
    # User provider. Used as a base class for {Resource::User}
    # providers.
    class User < Wright::Provider
      # Adds the user.
      #
      # @return [void]
      def create
        user = @resource.name
        unless_uptodate(:create, "user already created: '#{user}'") do
          create_user
        end
      end

      # Removes the user.
      #
      # @return [void]
      def remove
        user = @resource.name
        unless_uptodate(:remove, "user already removed: '#{user}'") do
          remove_user
        end
      end

      private

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

      def create_user
        unless_dry_run("create user: '#{@resource.name}'") do
          if user_exists?
            update_user
          else
            add_user
          end
        end
      end

      def remove_user
        unless_dry_run("remove user: '#{@resource.name}'") do
          delete_user
        end
      end

      def user_data
        Etc.getpwnam(@resource.name)
      rescue ArgumentError
        nil
      end

      def uid_uptodate?
        @resource.uid.nil? || user_data.uid == @resource.uid
      end

      def full_name_uptodate?
        @resource.full_name.nil? ||
          user_data.gecos.split(',').first == @resource.full_name
      end

      def groups_uptodate?
        return true if @resource.groups.nil?
        groups = []
        Etc.group { |g| groups << g.name if g.mem.include?(@resource.name) }
        groups.uniq.sort == @resource.groups.uniq.sort
      end

      def shell_uptodate?
        @resource.shell.nil? || user_data.shell == @resource.shell
      end

      def home_uptodate?
        @resource.home.nil? || user_data.dir == @resource.home
      end

      def primary_group_uptodate?
        return true if @resource.primary_group.nil?

        gid = Wright::Util::User.group_to_gid(@resource.primary_group)
        user_data.gid == gid
      end

      def user_exists?
        !user_data.nil?
      end

      def add_user
        fail NotImplementedError
      end

      def update_user
        fail NotImplementedError
      end

      def delete_user
        fail NotImplementedError
      end
    end
  end
end
