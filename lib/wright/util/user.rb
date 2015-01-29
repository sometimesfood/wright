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

      # Splits a colon-separated owner string into owner and group.
      #
      # @param owner [String] the owner string
      #
      # @example
      #   Wright::Util::User.owner_to_owner_group('foo:bar')
      #   # => ["foo", "bar"]
      #
      #   Wright::Util::User.owner_to_owner_group('foo')
      #   # => ["foo", nil]
      #
      #   Wright::Util::User.owner_to_owner_group(23)
      #   # => [23, nil]
      #
      # @return [Array<(String, String)>] the owner and group. Returns
      #   nil if no group was specified. Non-string owners are
      #   returned unmodified.
      # @raise [ArgumentError] if the owner string contains more than
      #   one colon
      def self.owner_to_owner_group(owner)
        group = nil
        return [owner, group] unless owner.is_a?(String)

        fail ArgumentError, "Invalid owner: '#{owner}'" if owner.count(':') > 1
        owner, group = owner.split(':')
        [owner, group]
      end
    end
  end
end
