require 'forwardable'

require 'wright/resource'
require 'wright/dsl'
require 'wright/util/file_owner'

module Wright
  class Resource
    # Symlink resource, represents a symlink.
    #
    # @example
    #   file = Wright::Resource::File.new('/tmp/foo')
    #   file.content = 'bar'
    #   file.create
    class File < Wright::Resource
      extend Forwardable

      # @return [String] the file's intended content
      attr_accessor :content

      # @return [String, Integer] the file's intended mode
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
      def_delegator :@owner, :group=
      def_delegator :@owner, :group

      # Initializes a File.
      #
      # @param name [String] the file's name
      def initialize(name)
        super
        @content = nil
        @mode = nil
        @owner = Wright::Util::FileOwner.new
        @action = :create
      end

      # Creates or updates the file.
      #
      # @return [Bool] true if the file was updated and false
      #   otherwise
      def create
        might_update_resource do
          @provider.create
        end
      end

      # Removes the file.
      #
      # @return [Bool] true if the file was updated and false
      #   otherwise
      def remove
        might_update_resource do
          @provider.remove
        end
      end
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::File)
