#!/usr/bin/env ruby1.9.1

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'wright/dsl'
require 'wright/resource/package'

include Wright::DSL

# use an existing resource
package "test" do |p|
  p.lalala = :dumdidum
  puts p
end

# define and register a new resource class at runtime
class TestClass
  def initialize(name); end
end
Wright::DSL.register_resource TestClass

f = test_class "hello" do |t|
  puts t
end
puts f.class

g = test_class 'foobar'
puts g.class

class Blubb < Wright::Resource; end
Wright::DSL.register_resource Blubb
blubb do |b|
  puts b
end

puts '#########################################'
require 'wright'
class Wright::Provider::Bla < Wright::Provider
  def install
    puts 'Bla: installing...'
    @updated = true
    raise 'oh noes!'
  end
end

class Bla < Wright::Resource
  def initialize(name)
    super
    @action = :install
  end

  def install
    maybe_destructive do
      @provider.install
    end
  end
end
Wright::DSL.register_resource Bla

bla "lalala-23" do |b|
  b.on_update = Proc.new { puts "Oh yeah!" }
  b.ignore_failure = true
end
