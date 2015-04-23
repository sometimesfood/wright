#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

file 'man/wright.1' => 'man/wright.1.txt' do
  sh 'a2x --format manpage man/wright.1.txt'
end

task build: 'man/wright.1'
