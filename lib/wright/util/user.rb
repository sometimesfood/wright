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
        to_id(user, :user)
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
        to_id(group, :group)
      end

      def self.to_id(object, type)
        fail ArgumentError unless [:group, :user].include?(type)
        return nil if object.nil?
        return object.to_i unless object.is_a?(String)
        type == :user ? Etc.getpwnam(object).uid : Etc.getgrnam(object).gid
      end
      private_class_method :to_id

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
        next_free_id(uid_range, :uid)
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
        next_free_id(gid_range, :gid)
      end

      def self.next_free_id(id_range, id_type)
        iterator = id_iterator(id_type)
        used_ids = []
        iterator.call do |o|
          id = o.method(id_type).call
          used_ids << id if id_range.include?(id)
        end
        free_ids = id_range.to_a - used_ids
        fail "No free #{id_type} in range #{id_range}" if free_ids.empty?
        free_ids.min
      end
      private_class_method(:next_free_id)

      def self.id_iterator(id_type)
        fail ArgumentError unless [:uid, :gid].include?(id_type)
        id_type == :uid ? Etc.method(:passwd) : Etc.method(:group)
      end
      private_class_method :id_iterator
    end
  end
end
