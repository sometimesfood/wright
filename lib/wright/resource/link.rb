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

  alias_method :target, :name
  alias_method :from,   :target
  alias_method :to,     :source
  alias_method :to=,    :source=

  def create!
    might_update_resource do
      @provider.create!
    end
  end

  def remove!
    might_update_resource do
      @provider.remove!
    end
  end
end

Wright::DSL.register_resource(Wright::Resource::Link)
