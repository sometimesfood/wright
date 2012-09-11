require 'wright/resource'
require 'wright/dsl'

class Wright::Resource::Link < Wright::Resource
  def initialize(resource)
    super
    @source = nil
    @action = :create
  end
  attr_accessor :source
  attr_reader   :target

  alias :target :name
  alias :from   :target
  alias :to     :source
  alias :to=    :source=

  def create!
    maybe_destructive do
      @provider.create!
    end
  end

  def remove!
    maybe_destructive do
      @provider.remove!
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Link)
