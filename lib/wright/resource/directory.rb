require 'forwardable'

require 'wright/resource'
require 'wright/dsl'
require 'wright/util/file_owner'

module Wright
  class Resource
    # Directory resource, represents a directory.
    #
    # @example
    #   dir = Wright::Resource::Directory.new('/tmp/foobar')
    #   dir.create
    class Directory < Wright::Resource
      extend Forwardable

      # Initializes a Directory.
      #
      # @param name [String] the directory's name
      def initialize(name)
        super
        @mode = nil
        @owner = Wright::Util::FileOwner.new
        @action = :create
      end

      # @return [String, Integer] the directory's intended mode
      attr_accessor :mode

      # @!attribute owner
      #   @return [String, Integer] the directory's intended owner
      # @!method owner=
      #   @see #owner
      def_delegator :@owner, :user_and_group=, :owner=
      def_delegator :@owner, :user, :owner

      # @!attribute group
      #   @return [String, Integer] the directory's intended group
      # @!method group=
      #   @see #group
      def_delegator :@owner, :group
      def_delegator :@owner, :group=

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
