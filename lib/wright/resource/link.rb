require 'wright/resource'
require 'wright/dsl'

# Public: Link resource, represents a symlink.
#
# Examples
#
#   link = Wright::Resource::Link.new('/tmp/fstab')
#   link.to = '/etc/fstab'
#   link.create!
class Wright::Resource::Link < Wright::Resource

  # Public: Initialize a Link.
  #
  # target - The link's target.
  def initialize(target)
    super
    @source = nil
    @action = :create
  end

  # Public: Gets/Sets the Link's source.
  attr_accessor :source

  # Public: Gets the Link's target
  attr_reader :target
  alias_method :target, :name

  # Public: Gets/Sets the Link's source.
  alias_method :to,     :source
  # Public: Gets/Sets the Link's source.
  alias_method :to=,    :source=

  # Public: Create or update the Link.
  #
  # Returns nothing.
  def create!
    might_update_resource do
      @provider.create!
    end
  end

  # Public: Remove the Link.
  #
  # Returns nothing.
  def remove!
    might_update_resource do
      @provider.remove!
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Link)
