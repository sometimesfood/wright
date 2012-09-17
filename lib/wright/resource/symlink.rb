require 'wright/resource'
require 'wright/dsl'

# Public: Symlink resource, represents a symlink.
#
# Examples
#
#   link = Wright::Resource::Symlink.new('/tmp/fstab')
#   link.to = '/etc/fstab'
#   link.create!
class Wright::Resource::Symlink < Wright::Resource

  # Public: Initialize a Symlink.
  #
  # name - The link's name.
  def initialize(name)
    super
    @to = nil
    @action = :create
  end

  # Public: Gets/Sets the link's target.
  attr_accessor :to

  # Public: Create or update the Symlink.
  #
  # Returns nothing.
  def create!
    might_update_resource do
      @provider.create!
    end
  end

  # Public: Remove the Symlink.
  #
  # Returns nothing.
  def remove!
    might_update_resource do
      @provider.remove!
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Symlink)
