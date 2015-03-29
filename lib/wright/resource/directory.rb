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
      attr_accessor :owner

      # @return [String] the directory's group
      attr_accessor :group

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
