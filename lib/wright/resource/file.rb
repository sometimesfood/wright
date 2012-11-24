require 'wright/resource'
require 'wright/dsl'

# Public: Symlink resource, represents a symlink.
#
# Examples
#
#   file = Wright::Resource::File.new('/tmp/foo')
#   file.content = 'bar'
#   file.create!
class Wright::Resource::File < Wright::Resource

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

  attr_accessor :content, :mode, :owner, :group

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

Wright::DSL.register_resource(Wright::Resource::File)
