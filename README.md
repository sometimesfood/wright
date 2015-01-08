wright
======

Lightweight configuration management.

Requirements
------------

 - Ruby 1.9

Documentation
-------------

There's not too much useful documentation at the moment. Run
`bundle exec rake rerdoc` to generate HTML documentation.

Installation
------------

 - Make sure `ruby --version` is at least 1.9.1. (If your distro
   doesn't use Ruby 1.9 by default, just use
   [rbenv](https://github.com/sstephenson/rbenv/) and
   [ruby-build](https://github.com/sstephenson/ruby-build/).)

 - Install bundler.

 - `cd ~/src/wright && bundle install --path vendor/bundle`

 - `bundle exec rake test`

All tests should pass.

Getting Started
---------------

To start a wright IRB session, simply run:

    $ bundle console

In order to create some resources using the wright DSL:

    include Wright::DSL
    
    foo_dir = directory '/tmp/foo'
    fstab = symlink '/tmp/foo/fstab' do |s|
      s.to = '/etc/fstab'
    end
    
    puts File.directory? '/tmp/foo'
    puts File.symlink? '/tmp/foo/fstab'
    
    fstab.remove
    foo_dir.remove

If you don't want to use the DSL:

    foo_dir = Wright::Resource::Directory.new('/tmp/foo')
    foo_dir.create
    fstab = Wright::Resource::Symlink.new('/tmp/foo/fstab')
    fstab.to = '/etc/fstab'
    fstab.create
   
    puts File.directory? '/tmp/foo'
    puts File.symlink? '/tmp/foo/fstab'
    
    fstab.remove
    foo_dir.remove

Copyright
---------

Copyright (c) 2012 Sebastian Boehm. See LICENSE for details.
