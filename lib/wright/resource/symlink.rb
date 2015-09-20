require 'wright/resource'
require 'wright/dsl'

module Wright
  class Resource
    # Symlink resource, represents a symlink.
    #
    # @example
    #   link = Wright::Resource::Symlink.new('/tmp/fstab', to: '/etc/fstab')
    #   link.create
    class Symlink < Wright::Resource
      # Initializes a Symlink.
      #
      # @param name [String] the symlink's name
      # @param args [Hash] the arguments
      # @option args [Symbol] :action (:create) the action
      # @option args [String] :to the symlink's target
      def initialize(name, args = {})
        super
        @action = args.fetch(:action, :create)
        @to     = args.fetch(:to, nil)
      end

      # @return [String] the symlink's intended target
      attr_accessor :to

      # Creates or updates the symlink.
      #
      # @return [Bool] true if the symlink was updated and false
      #   otherwise
      def create
        fail ArgumentError, 'Symlink target undefined' unless to
        might_update_resource do
          provider.create
        end
      end

      # Removes the symlink.
      #
      # @return [Bool] true if the symlink was updated and false
      #   otherwise
      def remove
        might_update_resource do
          provider.remove
        end
      end
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Symlink)
