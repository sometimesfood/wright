require 'wright/resource'
require 'wright/dsl'

module Wright
  class Resource
    # Symlink resource, represents a symlink.
    #
    # @example
    #   file = Wright::Resource::File.new('/tmp/foo')
    #   file.content = 'bar'
    #   file.create
    class File < Wright::Resource
      # @return [String] the file's intended content
      attr_accessor :content

      # @return [String] the file's intended group
      attr_accessor :group

      # @return [String, Integer] the file's intended mode
      attr_accessor :mode

      # @return [String] the file's intended owner
      attr_reader :owner

      # Initializes a File.
      #
      # @param name [String] the file's name
      def initialize(name)
        super
        @content = nil
        @mode = nil
        @owner = nil
        @group = nil
        @action = :create
      end

      # Sets the file's owner.
      def owner=(owner)
        target_owner, target_group =
          Wright::Util::User.owner_to_owner_group(owner)
        @owner = target_owner unless target_owner.nil?
        @group = target_group unless target_group.nil?
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
