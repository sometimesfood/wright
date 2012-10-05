#!/usr/bin/env ruby

require 'bundler/setup'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'wright'
require 'wright/resource/symlink'

include Wright::DSL

Wright.dry_run do
  # use an existing resource
  symlink '/tmp/fstab' do |l|
    l.to = '/etc/fstab'
    puts l
  end
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
  def install!
    puts 'Bla: installing...'
    @updated = true
#    raise 'oh noes!'
  end
end

class Bla < Wright::Resource
  def initialize(name)
    super
    @action = :install
  end

  def install!
    might_update_resource do
      @provider.install!
    end
  end

  def something_else
    puts "something else..."
  end
end
Wright::DSL.register_resource Bla

bla "lalala-23" do |b|
#  b.provider = Wright::Provider::Bla.new(b)
#  b.provider = Wright::Provider::Bla
  b.on_update = Proc.new { puts "Oh yeah!" }
  b.action = :something_else
  b.ignore_failure = true
end
