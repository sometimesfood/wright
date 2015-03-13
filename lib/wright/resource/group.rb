require 'wright/resource'
require 'wright/dsl'

module Wright
  class Resource
    # Group resource, represents a group.
    #
    # @example
    #   admins = Wright::Resource::Group.new('admins')
    #   admins.members = ['root']
    #   admins.create
    # @todo Use GnuPasswd provider on all GNU-flavoured systems
    class Group < Wright::Resource
      # @return [Array<String>] the group's intended members
      attr_accessor :members

      # @return [Integer] the group's intended group id
      attr_accessor :gid

      # @return [Bool] true if the group should be a system
      #   group. Ignored if {#gid} is set.
      attr_accessor :system

      # Initializes a Group.
      #
      # @param name [String] the group's name
      def initialize(name)
        super
        @action = :create
        @system = false
      end

      # Creates or updates the group.
      #
      # @return [Bool] true if the group was updated and false
      #   otherwise
      def create
        might_update_resource do
          @provider.create
        end
      end

      # Removes the group.
      #
      # @return [Bool] true if the group was updated and false
      #   otherwise
      def remove
        might_update_resource do
          @provider.remove
        end
      end
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Group)

group_providers = {
  'debian' => 'Wright::Provider::Group::GnuPasswd',
  'macosx' => 'Wright::Provider::Group::DarwinDirectoryService'
}
Wright::Config[:resources][:group] ||= {}
Wright::Config[:resources][:group][:provider] ||=
  group_providers[Wright::Util.os_family]
