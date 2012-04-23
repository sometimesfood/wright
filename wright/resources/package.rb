require 'wright/resource'
module Wright
  class Package
    attr_reader :name
    attr_accessor :lalala

    def initialize(name)
      @name = name
      @lalala = :blablabla
    end

    def to_s
      "#{self.class} '#{@name}': @lalala=#{@lalala}"
    end
  end
end

Wright::Resource.register Wright::Package
