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

      # Returns the the next free uid in a range.
      #
      # @param uid_range [Range] the uid range
      #
      # @example
      #   Wright::Util::User.next_free_uid(1...500)
      #   # => 2
      #
      # @return [Integer] the next free uid
      # @raise [RuntimeError] if there are no free uids in the range
      def self.next_free_uid(uid_range)
        used_uids = []
        Etc.passwd { |u| used_uids << u.uid if uid_range.include?(u.uid) }
        free_uids = uid_range.to_a - used_uids
        fail "No free uids in uid range #{uid_range}" if free_uids.empty?
        free_uids.min
      end

      # Returns the the next free gid in a range.
      #
      # @param gid_range [Range] the gid range
      #
      # @example
      #   Wright::Util::User.next_free_gid(1...500)
      #   # => 11
      #
      # @return [Integer] the next free gid
      # @raise [RuntimeError] if there are no free gids in the range
      def self.next_free_gid(gid_range)
        used_gids = []
        Etc.group { |g| used_gids << g.gid if gid_range.include?(g.gid) }
        free_gids = gid_range.to_a - used_gids
        fail "No free gids in gid range #{gid_range}" if free_gids.empty?
        free_gids.max
      end
    end
  end
end
