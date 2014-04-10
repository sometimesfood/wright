require 'wright/resource'
require 'wright/dsl'

# Public: Directory resource, represents a directory.
#
# Examples
#
#   dir = Wright::Resource::Directory.new('/tmp/foobar')
#   dir.create!
class Wright::Resource::Directory < Wright::Resource

  # Public: Initialize a Directory.
  #
  # name - The directory's name.
  def initialize(name)
    super
    @mode = nil
    @owner = nil
    @group = nil
    @action = :create
  end

  # Public: Gets/Sets the directory's mode.
  attr_accessor :mode

  # Public: Gets the directory's owner.
  attr_reader :owner

  # Public: Sets the directory's owner.
  def owner=(owner)
    if owner.is_a?(String)
      raise ArgumentError, "Invalid owner: '#{owner}'" if owner.count(':') > 1
      owner, group = owner.split(':')
      @group = Util::User.group_to_gid(group) unless group.nil?
    end
    @owner = Util::User.user_to_uid(owner)
  end

  # Public: Gets the directory's group.
  attr_reader :group

  # Public: Sets the directory's group
  def group=(group)
    @group = Util::User.group_to_gid(group)
  end

  # Public: Create or update the directory.
  #
  # Returns true if the directory was updated and false otherwise.
  def create!
    might_update_resource do
      @provider.create!
    end
  end

  # Public: Remove the directory.
  #
  # Returns true if the directory was updated and false otherwise.
  def remove!
    might_update_resource do
      @provider.remove!
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Directory)
