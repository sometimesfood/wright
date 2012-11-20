#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

RDoc::Task.new do |t|
  t.rdoc_files.include('lib/**/*.rb')
  t.options << '--markup=tomdoc'
end

desc 'Start wright IRB session'
task :console do
  ENV['RUBYLIB'] = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
  exec 'irb -r wright -r wright/resource/symlink -r wright/resource/directory'
end
