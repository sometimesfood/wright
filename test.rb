#!/usr/bin/env ruby

require 'bundler/setup'

$LOAD_PATH.unshift File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

require 'wright'
require 'wright/resource/symlink'
require 'wright/resource/file'
require 'wright/resource/directory'
require 'wright/resource/package'

include Wright::DSL

Wright.dry_run do
  Wright.log.level = Wright::Logger::DEBUG
  emacs = package 'emacs29' do |p|
    p.action = nil
  end

  installed_version = emacs.installed_version
  puts "installed version: #{installed_version}" if installed_version
  emacs.install
end
