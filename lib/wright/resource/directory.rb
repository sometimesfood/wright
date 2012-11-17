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
    @action = :create
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
