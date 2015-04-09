require 'wright/resource'
require 'wright/dsl'

module Wright
  class Resource
    # User resource, represents a user.
    #
    # @example
    #   johndoe = Wright::Resource::User.new('johndoe')
    #   johndoe.home = '/home/johndoe'
    #   johndoe.create
    class User < Wright::Resource
      # @return [Integer] the user's intended user id
      attr_accessor :uid

      # @return [String] the user's intended full name
      attr_accessor :full_name

      # @return [Array<String>] the user's intended groups
      attr_accessor :groups

      # @return [String] the user's intended shell
      attr_accessor :shell

      # @return [String] the user's intended home directory path
      attr_accessor :home
      alias_method :homedir, :home

      # @return [String, Integer] the user's intended primary group
      attr_accessor :primary_group
      alias_method :login_group, :primary_group

      # @return [Bool] true if the user should be a system
      #   user. Ignored if {#uid} is set.
      attr_accessor :system

      # Initializes a user.
      #
      # @param name [String] the user's name
      def initialize(name)
        super
        @action = :create
        @system = false
      end

      # Creates or updates the user.
      #
      # @return [Bool] true if the user was updated and false
      #   otherwise
      def create
        might_update_resource do
          @provider.create
        end
      end

      # Removes the user.
      #
      # @return [Bool] true if the user was updated and false
      #   otherwise
      def remove
        might_update_resource do
          @provider.remove
        end
      end
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::User)

user_providers = {
  'debian' => 'Wright::Provider::User::GnuPasswd',
  'macosx' => 'Wright::Provider::User::DarwinDirectoryService'
}
Wright::Config[:resources][:user] ||= {}
Wright::Config[:resources][:user][:provider] ||=
  user_providers[Wright::Util.os_family]
