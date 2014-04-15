#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc 'Start wright IRB session'
task :console do
  exec 'irb -I lib -r wright'
end

RDoc::Task.new(clobber_rdoc: 'rdoc:clobber',
               rerdoc: 'rdoc:force') do |t|
  t.rdoc_files.include('lib/**/*.rb')
  t.options << '--markup=tomdoc'
end

namespace :rdoc do
  desc 'Show RDoc coverage report'
  task :coverage do
    exec 'rdoc --markup=tomdoc --coverage-report lib/'
  end
end
