require 'wright/util/stolen_from_activesupport'

module Wright
  # Internal: Various utility functions.
  module Util
    # Internal: Get the resource name corresponding to a class.
    #
    # klass - The class constant for which to get the resource name.
    #
    # Examples
    #
    #   Wright::Util.class_to_resource_name(Wright::Resource::Package)
    #   # => "package"
    #
    #   Wright::Util.class_to_resource_name(Foo::Bar::BazQux)
    #   # => "baz_qux"
    #
    # Returns the String resource name of the given class.
    def self.class_to_resource_name(klass)
      ActiveSupport.underscore(klass.name).split('/').last
    end

    # Internal: Get the class name corresponding to a file path.
    #
    # filename - The filename for which to get the class name.
    #
    # Examples
    #
    #   Wright::Util.filename_to_classname("foo/bar/baz.rb")
    #   # => "Foo::Bar::Baz"
    #
    #   Wright::Util.filename_to_classname("foo/bar/")
    #   # => "Foo::Bar"
    #
    # Returns the String class name for the given filename.
    def self.filename_to_classname(filename)
      ActiveSupport.camelize(filename.chomp('.rb').chomp('/'))
    end

    def self.distro
      os_release = ::File.read('/etc/os-release')
      /^ID_LIKE=(?<id_like>.*)$/ =~ os_release
      /^ID=(?<id>.*)$/ =~ os_release
      id_like || id || 'linux'
    end
    private_class_method :distro

    # Internal: Get the system's OS family.
    #
    # Examples
    #
    #   Wright::Util.os_family
    #   # => "debian"
    #
    #   Wright::Util.os_family
    #   # => "macosx"
    #
    # Returns the String system OS family (base distribution for
    # GNU/Linux systems) or 'other' for unknown operating systems.
    def self.os_family
      system_arch = RbConfig::CONFIG['target_os']
      case system_arch
      when /darwin/
        'macosx'
      when /linux/
        distro
      else
        'other'
      end
    end
  end
end
