require 'wright/util'

module Wright
  module Util
    module RecursiveAutoloader
      def self.add_autoloads_for_current_dir(parent_class)
        klass = Wright::Util.constantize(parent_class)
        Dir['*.rb'].each do |filename|
          classname = "#{Wright::Util.filename_to_classname(filename)}"
          klass.autoload classname, File.expand_path(filename)
        end
      end

      def self.ensure_subclass_exists(classname, subclass)
        complete_classname = "#{classname}::#{subclass}"
        return true if class_exists(complete_classname)
        klass = Wright::Util.constantize(classname)
        klass.const_set(subclass, Class.new)
      end

      def self.class_exists(classname)
        !Wright::Util.safe_constantize(classname).nil?
      end

      def self.add_autoloads(directory, parent_class)
        unless class_exists(parent_class)
          raise ArgumentError.new("Can't resolve parent_class #{parent_class}")
        end

        Dir.chdir(directory) do
          add_autoloads_for_current_dir(parent_class)
          Dir['*/'].each do |dir|
            subclass = Wright::Util.filename_to_classname(dir)
            ensure_subclass_exists(parent_class, subclass)
            new_parent = Wright::Util.filename_to_classname(
                                           File.join(parent_class, dir))
            add_autoloads(dir, new_parent)
          end
        end
      end
    end
  end
end
