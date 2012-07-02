require 'wright/util/stolen_from_activesupport'

module Wright
  module Util
    def self.class_to_resource_name(klass)
      underscore(klass.name).split('/').last
    end

    def self.filename_to_classname(filename)
      camelize(filename.chomp('.rb'))
    end
  end
end
