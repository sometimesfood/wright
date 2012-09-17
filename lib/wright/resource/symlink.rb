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
  # target - The link's target.
  def initialize(target)
    super
    @source = nil
    @action = :create
  end

  # Public: Gets/Sets the Symlink's source.
  attr_accessor :source

  # Public: Gets the Symlink's target
  attr_reader :target
  alias_method :target, :name

  # Public: Gets/Sets the Symlink's source.
  alias_method :to,     :source
  # Public: Gets/Sets the Symlink's source.
  alias_method :to=,    :source=

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
