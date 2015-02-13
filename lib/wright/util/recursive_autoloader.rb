require 'wright/util'

module Wright
  module Util
    # Recursive autoloader, recursively adds autoloads for all files
    # in a directory.
    module RecursiveAutoloader
      # Adds autoloads for all files in a directory to a parent class.
      #
      # Registers all files in directory to be autoloaded the
      # first time ParentClass::CamelCased::FileName is accessed.
      #
      # @param directory [String] the path of the directory containing
      #   the files to be autoloaded
      # @param parent_class [String] the parent class to add the
      #   autoloads to
      #
      # @example
      #   require 'fileutils'
      #
      #   # set up a test directory
      #   FileUtils.cd '/tmp'
      #   FileUtils.mkdir_p 'somedir/foo'
      #   File.write('somedir/foo/bar_baz.rb', 'class Root::Foo::BarBaz; end')
      #
      #   # define a root class, add an autoload
      #   class Root; end
      #   Wright::Util::RecursiveAutoloader.add_autoloads('somedir', 'Root')
      #
      #   # Root::Foo::BarBaz is going to be autoloaded
      #   Root::Foo.autoload? 'BarBaz'
      #   # => "/tmp/somedir/foo/bar_baz.rb"
      #
      #   # instantiate Root::Foo::BarBaz, somedir/foo/bar_baz.rb is loaded
      #   foo_bar_baz = Root::Foo::BarBaz.new
      #   foo_bar_baz.class
      #   # => Root::Foo::BarBaz
      #
      #   # at this point, somedir/foo/bar_baz.rb has already been loaded
      #   Root::Foo.autoload? 'BarBaz'
      #   # => nil
      #
      # @return [void]
      # @raise [ArgumentError] if the parent class cannot be resolved
      def self.add_autoloads(directory, parent_class)
        unless class_exists?(parent_class)
          fail ArgumentError, "Can't resolve parent_class #{parent_class}"
        end
        add_autoloads_unsafe(directory, parent_class)
      end

      def self.add_autoloads_for_current_dir(parent_class)
        klass = Wright::Util::ActiveSupport.constantize(parent_class)
        Dir['*.rb'].each do |filename|
          classname = "#{Wright::Util.filename_to_classname(filename)}"
          klass.autoload classname, ::File.expand_path(filename)
        end
      end
      private_class_method :add_autoloads_for_current_dir

      def self.ensure_subclass_exists(classname, subclass)
        complete_classname = "#{classname}::#{subclass}"
        return true if class_exists?(complete_classname)
        klass = Wright::Util::ActiveSupport.constantize(classname)
        klass.const_set(subclass, Class.new)
      end
      private_class_method :ensure_subclass_exists

      def self.class_exists?(classname)
        !Wright::Util::ActiveSupport.safe_constantize(classname).nil?
      end
      private_class_method :class_exists?

      def self.add_autoloads_unsafe(directory, parent_class)
        Dir.chdir(directory) do
          add_autoloads_for_current_dir(parent_class)
          Dir['*/'].each do |dir|
            subclass = Wright::Util.filename_to_classname(dir)
            ensure_subclass_exists(parent_class, subclass)
            new_parent = Wright::Util.filename_to_classname(
              ::File.join(parent_class, dir))
            add_autoloads_unsafe(dir, new_parent)
          end
        end
      end
      private_class_method :add_autoloads_unsafe
    end
  end
end
