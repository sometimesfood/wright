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
      # Returns the integer uid of the given user or nil if user was
      # nil.
      def self.user_to_uid(user)
        return nil if user.nil?
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
      # Returns the integer gid of the given group or nil if group was
      # nil.
      def self.group_to_gid(group)
        return nil if group.nil?
        group.is_a?(String) ? Etc.getgrnam(group).gid : group.to_i
      end

      # Internal: Split a colon-separated owner string into owner and
      #           group.
      #
      # owner - The owner string
      #
      # Examples
      #
      #   Wright::Util::User.owner_to_owner_group('foo:bar')
      #   # => ["foo", "bar"]
      #
      #   Wright::Util::User.owner_to_owner_group('foo')
      #   # => ["foo", nil]
      #
      #   Wright::Util::User.owner_to_owner_group(23)
      #   # => [23, nil]
      #
      # Returns the owner and group. Returns nil if no group was
      #   specified. Non-string owners are returned unmodified.
      # Raises ArgumentError if the owner string contains more than
      #   one colon.
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
