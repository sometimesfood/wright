#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.pattern = 'spec/*_spec.rb'
end

RDoc::Task.new do |t|
  t.rdoc_files.include('lib/**/*.rb')
  t.options << '--markup=tomdoc'
end
