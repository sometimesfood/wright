module Wright
  module Util
    # Helper class to support +user:group+ notation in file owner
    # strings.
    class FileOwner
      # @return [String, Integer] the user's name or uid
      attr_accessor :user

      # @return [String, Integer] the group's name or gid
      attr_accessor :group

      # Sets user and group simultaneously.
      #
      # @param [String, Integer] user_and_group a user in +user:group+
      #   notation or a uid
      #
      # @example
      #   owner = FileOwner.new
      #
      #   owner.user_and_group = 'user:group'
      #   owner.user
      #   # => "user"
      #   owner.group
      #   # => "group"
      #
      #   owner.user_and_group = 'newuser'
      #   owner.user
      #   # => "newuser"
      #   owner.group
      #   # => "group"
      #
      #   owner.user_and_group = 42
      #   owner.user
      #   # => 42
      #
      # @return [void]
      # @raise [ArgumentError] if the owner string contains more than
      #   one colon
      def user_and_group=(user_and_group)
        user, group = split_user_and_group(user_and_group)
        @user = user
        @group = group if group
      end

      private

      def split_user_and_group(user_and_group)
        user = user_and_group
        group = nil
        return [user, group] unless user_and_group.is_a?(String)

        if user_and_group.count(':') > 1
          fail ArgumentError, "Invalid owner: '#{user_and_group}'"
        end

        user, group = user_and_group.split(':')
        [user, group]
      end
    end
  end
end
