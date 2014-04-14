require 'wright/resource'
require 'wright/dsl'

module Wright
  class Resource
    # Public: Symlink resource, represents a symlink.
    #
    # Examples
    #
    #   file = Wright::Resource::File.new('/tmp/foo')
    #   file.content = 'bar'
    #   file.create!
    class File < Wright::Resource
      attr_accessor :content, :group, :mode
      attr_reader :owner

      # Public: Initialize a File.
      #
      # name - The file's name.
      def initialize(name)
        super
        @content = nil
        @mode = nil
        @owner = nil
        @group = nil
        @action = :create
      end

      # Public: Set the file's owner.
      def owner=(owner)
        target_owner, target_group =
          Wright::Util::User.owner_to_owner_group(owner)
        @owner = target_owner unless target_owner.nil?
        @group = target_group unless target_group.nil?
      end

      # Public: Create or update the File.
      #
      # Returns true if the file was updated and false otherwise.
      def create!
        might_update_resource do
          @provider.create!
        end
      end

      # Public: Remove the File.
      #
      # Returns true if the file was updated and false otherwise.
      def remove!
        might_update_resource do
          @provider.remove!
        end
      end
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::File)
