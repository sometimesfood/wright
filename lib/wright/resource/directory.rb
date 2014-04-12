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

  # Public: Get/Set the directory's mode.
  attr_accessor :mode

  # Public: Get the directory's owner.
  attr_reader :owner

  # Public: Set the directory's owner.
  def owner=(owner)
    target_owner, target_group = Wright::Util::User.owner_to_owner_group(owner)
    @owner = target_owner unless target_owner.nil?
    @group = target_group unless target_group.nil?
  end

  # Public: Get the directory's group.
  attr_reader :group

  # Public: Set the directory's group
  def group=(group)
    @group = Wright::Util::User.group_to_gid(group)
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
