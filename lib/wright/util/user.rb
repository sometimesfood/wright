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
        next_free_id(:uid, uid_range)
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
        next_free_id(:gid, gid_range)
      end

      def self.next_free_id(id_type, id_range)
        fail ArgumentError unless [:uid, :gid].include?(id_type)
        used_ids = []
        iterator = id_type == :uid ? Etc.method(:passwd) : Etc.method(:group)
        iterator.call do |o|
          id = o.method(id_type).call
          used_ids << id if id_range.include?(id)
        end
        free_ids = id_range.to_a - used_ids
        fail "No free #{id_type} in range #{id_range}" if free_ids.empty?
        free_ids.min
      end
      private_class_method(:next_free_id)
    end
  end
end
