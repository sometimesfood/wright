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
      # @param args [Hash] the arguments
      # @option args [Symbol] :action (:create) the action
      # @option args [Integer] :uid the user's uid
      # @option args [String] :full_name the user's full name
      # @option args [Array<String>] :groups the user's groups
      # @option args [String] :shell the user's shell
      # @option args [String] :home the user's home directory
      # @option args [String] :primary_group the user's primary group
      # @option args [Bool] :system (false) denotes whether the user
      #   should be a system user or not
      def initialize(name, args = {})
        super
        @action        = args.fetch(:action, :create)
        @uid           = args.fetch(:uid, nil)
        @full_name     = args.fetch(:full_name, nil)
        @groups        = args.fetch(:groups, nil)
        @shell         = args.fetch(:shell, nil)
        @home          = args.fetch(:home, nil)
        @primary_group = args.fetch(:primary_group, nil)
        @system        = args.fetch(:system, false)
        alias_args(args, login_group: :primary_group, homedir: :home)
      end

      # Creates or updates the user.
      #
      # @return [Bool] true if the user was updated and false
      #   otherwise
      def create
        might_update_resource do
          provider.create
        end
      end

      # Removes the user.
      #
      # @return [Bool] true if the user was updated and false
      #   otherwise
      def remove
        might_update_resource do
          provider.remove
        end
      end

      private

      def alias_args(args, aliases)
        aliases.each do |method_alias, method|
          key = "@#{method}".to_sym
          value = args.fetch(method_alias, nil)
          instance_variable_set(key, value) unless args.key?(method)
        end
      end
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::User)

user_providers = {
  'debian' => 'Wright::Provider::User::GnuPasswd',
  'rhel'   => 'Wright::Provider::User::GnuPasswd',
  'fedora' => 'Wright::Provider::User::GnuPasswd',
  'macosx' => 'Wright::Provider::User::DarwinDirectoryService'
}
Wright::Config[:resources][:user] ||= {}
Wright::Config[:resources][:user][:provider] ||=
  user_providers[Wright::Util.os_family]
