require 'wright/util/stolen_from_activesupport'

module Wright
  # @api private
  # Various utility functions.
  module Util
    # Converts a class constant into its corresponding resource name.
    #
    # @param klass [Class] the class constant
    #
    # @example
    #   Wright::Util.class_to_resource_name(Wright::Resource::Package)
    #   # => "package"
    #
    #   Wright::Util.class_to_resource_name(Foo::Bar::BazQux)
    #   # => "baz_qux"
    #
    # @return [String] the resource name of the given class
    def self.class_to_resource_name(klass)
      ActiveSupport.underscore(klass.name).split('/').last
    end

    # Converts a file path into its corresponding class name.
    #
    # @param filename [String] the filename
    #
    # @example
    #   Wright::Util.filename_to_classname('foo/bar/baz.rb')
    #   # => "Foo::Bar::Baz"
    #
    #   Wright::Util.filename_to_classname('foo/bar/')
    #   # => "Foo::Bar"
    #
    # @return [String] the class name for the given filename
    def self.filename_to_classname(filename)
      ActiveSupport.camelize(filename.chomp('.rb').chomp('/'))
    end

    def self.distro
      default = 'linux'
      release_file = '/etc/os-release'
      return default unless ::File.exist?(release_file)

      os_release = ::File.read(release_file)
      /^ID_LIKE="?(?<id_like>[^"]*)"?$/ =~ os_release
      /^ID="?(?<id>[^"]*)"?$/ =~ os_release
      return id_like.split(' ').first if id_like
      id || default
    end
    private_class_method :distro

    # Determines the system's OS family.
    #
    # @example
    #   Wright::Util.os_family
    #   # => "debian"
    # @example
    #   Wright::Util.os_family
    #   # => "macosx"
    #
    # @return [String] the system's OS family (base distribution for
    #   GNU/Linux systems) or 'other' for unknown operating systems
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

    # Runs a code block in a clean bundler environment.
    #
    # @example
    #   Wright::Util.bundler_clean_env { `brew search /^git$/` }
    #   # => "git\n"
    # @return [Object] the return value of the code block
    def self.bundler_clean_env
      if defined?(Bundler)
        Bundler.with_clean_env { yield }
      else
        yield
      end
    end
  end
end
