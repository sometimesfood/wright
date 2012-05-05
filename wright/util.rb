require 'wright/util/stolen_from_activesupport'

module Wright
  module Util
    def self.class_to_resource_name(klass)
      underscore(klass.name).split('/').last
    end
  end
end
