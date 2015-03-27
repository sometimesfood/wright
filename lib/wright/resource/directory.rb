require 'wright/resource'
require 'wright/dsl'

module Wright
  class Resource
    # Directory resource, represents a directory.
    #
    # @example
    #   dir = Wright::Resource::Directory.new('/tmp/foobar')
    #   dir.create
    class Directory < Wright::Resource
      # Initializes a Directory.
      #
      # @param name [String] the directory's name
      def initialize(name)
        super
        @mode = nil
        @owner = nil
        @group = nil
        @action = :create
      end

      # @return [String, Integer] the directory's mode
      attr_accessor :mode

      # @return [String] the directory's owner
      attr_reader :owner

      # Sets the directory's owner.
      def owner=(owner)
        target_owner, target_group =
          Wright::Util::User.owner_to_owner_group(owner)
        @owner = target_owner if target_owner
        @group = target_group if target_group
      end

      # @return [String] the directory's group
      attr_reader :group

      # Sets the directory's group.
      def group=(group)
        @group = Wright::Util::User.group_to_gid(group)
      end

      # Creates or updates the directory.
      #
      # @return [Bool] true if the directory was updated and false
      #   otherwise
      def create
        might_update_resource do
          @provider.create
        end
      end

      # Removes the directory.
      #
      # @return [Bool] true if the directory was updated and false
      #   otherwise
      def remove
        might_update_resource do
          @provider.remove
        end
      end
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Directory)
