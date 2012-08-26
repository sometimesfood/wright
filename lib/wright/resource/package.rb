require 'wright/dsl'
require 'wright/resource'

class Wright::Resource::Package < Wright::Resource
  attr_reader :name
  attr_accessor :lalala

  def initialize(name)
    super
    @lalala = :blablabla
  end

  def to_s
    "#{self.class} '#{@name}': @lalala=#{@lalala}"
  end
end

Wright::DSL.register_resource Wright::Resource::Package
