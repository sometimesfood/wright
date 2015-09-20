require 'forwardable'

require 'wright/resource'
require 'wright/dsl'
require 'wright/util/file_owner'

module Wright
  class Resource
    # Symlink resource, represents a symlink.
    #
    # @example
    #   file = Wright::Resource::File.new('/tmp/foo', content: 'bar')
    #   file.create
    class File < Wright::Resource
      extend Forwardable

      # @return [String, #to_s] the file's intended content
      attr_accessor :content

      # @return [String, Integer] the file's intended mode
      attr_accessor :mode

      # @!attribute owner
      #   @return [String, Integer] the directory's intended owner
      # @!method owner=
      #   @see #owner
      def_delegator :file_owner, :user_and_group=, :owner=
      def_delegator :file_owner, :user, :owner

      # @!attribute group
      #   @return [String, Integer] the directory's intended group
      # @!method group=
      #   @see #group
      def_delegator :file_owner, :group=
      def_delegator :file_owner, :group

      # Initializes a File.
      #
      # @param name [String] the file's name
      # @param args [Hash] the arguments
      # @option args [Symbol] :action (:create) the action
      # @option args [String, #to_s] :content the file's content
      # @option args [String, Integer] :mode the file's mode
      # @option args [String, Integer] :owner the file's owner
      # @option args [String, Integer] :group the file's group
      def initialize(name, args = {})
        super
        @action     = args.fetch(:action, :create)
        @content    = args.fetch(:content, nil)
        @mode       = args.fetch(:mode, nil)
        owner       = args.fetch(:owner, nil)
        group       = args.fetch(:group, nil)
        @file_owner = Wright::Util::FileOwner.new(owner, group)
      end

      # Creates or updates the file.
      #
      # @return [Bool] true if the file was updated and false
      #   otherwise
      def create
        might_update_resource do
          provider.create
        end
      end

      # Removes the file.
      #
      # @return [Bool] true if the file was updated and false
      #   otherwise
      def remove
        might_update_resource do
          provider.remove
        end
      end

      private

      attr_reader :file_owner
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::File)
