require_relative 'spec_helper'

require 'wright/util/recursive_autoloader'

BASEDIR = File.expand_path('recursive_autoloader', File.dirname(__FILE__))
Wright::Util::RecursiveAutoloader.add_autoloads(BASEDIR, 'Wright')

describe Wright::Util::RecursiveAutoloader do
  it 'should not load files prematurely' do
    -> { Wright::RaisesException }.must_raise(RuntimeError)
  end

  it 'should load files when needed' do
    assert Wright.autoload?(:LoadedOnDemand)
    loaded = Wright::LoadedOnDemand.new
    assert loaded.was_loaded
  end

  it 'should load files in subdirectories' do
    assert Wright::Foo::Bar.autoload?(:Baz)
    baz = Wright::Foo::Bar::Baz.new
    assert baz.was_loaded
  end

  it 'should throw exceptions for unknown base classes' do
    lambda do
      baseclass = 'This::Class::Does::Not::Exist'
      Wright::Util::RecursiveAutoloader.add_autoloads(BASEDIR, baseclass)
    end.must_raise(ArgumentError)
  end

  it 'should autoload existing classes before creating them itself' do
    dir  = File.join(BASEDIR, 'identically_named_dir_and_file/')
    file = File.join(BASEDIR, 'identically_named_dir_and_file.rb')
    assert File.exist?(dir)
    assert File.exist?(file)

    Wright.autoload?(:IdenticallyNamedDirAndFile).must_be_nil
    assert Wright::IdenticallyNamedDirAndFile.new.was_loaded
  end
end
