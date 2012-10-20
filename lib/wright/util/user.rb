require 'etc'

module Wright
  module Util

    # Internal: Various user utility functions.
    module User

      # Internal: Get a user's uid.
      #
      # user - The user name or uid.
      #
      # Examples
      #
      #   Wright::Util::User.user_to_uid('root')
      #   # => 0
      #
      #   Wright::Util::User.user_to_uid(0)
      #   # => 0
      #
      # Returns the integer uid of the given user.
      def self.user_to_uid(user)
        user.is_a?(String) ? Etc.getpwnam(user).uid : user.to_i
      end

      # Internal: Get a group's gid.
      #
      # group - The group name or gid.
      #
      # Examples
      #
      #   Wright::Util::User.group_to_gid('root')
      #   # => 0
      #
      #   Wright::Util::User.group_to_gid(0)
      #   # => 0
      #
      # Returns the integer gid of the given group.
      def self.group_to_gid(group)
        group.is_a?(String) ? Etc.getgrnam(group).gid : group.to_i
      end
    end
  end
end