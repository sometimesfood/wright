require 'etc'

module Wright
  module Util
    # Various user utility functions.
    module User
      # Returns a user's uid.
      #
      # @param user [String, Integer] the user's name or uid
      #
      # @example
      #   Wright::Util::User.user_to_uid('root')
      #   # => 0
      #
      #   Wright::Util::User.user_to_uid(0)
      #   # => 0
      #
      # @return [Integer] the integer uid of the given user or nil if
      #   user was nil
      def self.user_to_uid(user)
        return nil if user.nil?
        user.is_a?(String) ? Etc.getpwnam(user).uid : user.to_i
      end

      # Returns a group's gid.
      #
      # @param group [String, Integer] the group's name or gid
      #
      # @example
      #   Wright::Util::User.group_to_gid('root')
      #   # => 0
      #
      #   Wright::Util::User.group_to_gid(0)
      #   # => 0
      #
      # @return [Integer] the integer gid of the given group or nil if
      #   group was nil
      def self.group_to_gid(group)
        return nil if group.nil?
        group.is_a?(String) ? Etc.getgrnam(group).gid : group.to_i
      end
    end
  end
end
