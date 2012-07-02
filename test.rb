#!/usr/bin/env ruby1.9.1

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'wright/resource'
require 'wright/resources/package'

include Wright::Resource

# use an existing resource
package "test" do |p|
  p.lalala = :dumdidum
  puts p
end

# define and register a new resource class at runtime
class TestClass
  def initialize(name); end
end
Wright::Resource.register TestClass

f = test_class "hello" do |t|
  puts t
end
puts f.class

g = test_class 'foobar'
puts g.class

class Blubb; end
Wright::Resource.register Blubb
blubb do |b|
  puts b
end