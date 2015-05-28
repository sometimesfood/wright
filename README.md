wright
======

[![Gem Version](https://img.shields.io/gem/v/wright.svg?style=flat-square)][gem]
[![Build Status](https://img.shields.io/travis/sometimesfood/wright.svg?style=flat-square)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/sometimesfood/wright.svg?style=flat-square)][codeclimate]
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/sometimesfood/wright.svg?style=flat-square)][codeclimate]
[![Gem Dependencies](https://img.shields.io/gemnasium/sometimesfood/wright.svg?style=flat-square)][gemnasium]

[gem]: https://rubygems.org/gems/wright
[travis]: https://travis-ci.org/sometimesfood/wright
[codeclimate]: https://codeclimate.com/github/sometimesfood/wright
[gemnasium]: https://gemnasium.com/sometimesfood/wright

Lightweight configuration management.

Getting Started
---------------

To start a wright IRB session, simply run:

    $ bundle console

In order to create some resources using the wright DSL:

```ruby
require 'wright'
extend Wright::DSL

foo_dir = directory '/tmp/foo'
fstab = symlink '/tmp/foo/fstab' do |s|
  s.to = '/etc/fstab'
end

puts File.directory? '/tmp/foo'
puts File.symlink? '/tmp/foo/fstab'

fstab.remove
foo_dir.remove
```

If you don't want to use the DSL:

```ruby
require 'wright'

foo_dir = Wright::Resource::Directory.new('/tmp/foo')
foo_dir.create
fstab = Wright::Resource::Symlink.new('/tmp/foo/fstab')
fstab.to = '/etc/fstab'
fstab.create

puts File.directory? '/tmp/foo'
puts File.symlink? '/tmp/foo/fstab'

fstab.remove
foo_dir.remove
```

Installation
------------

Since wright does not have any runtime dependencies apart from Ruby
≥1.9, it can safely be installed system-wide via rubygems:

    sudo gem install wright

If you use a Debian-based GNU/Linux distribution such as Ubuntu, you
can also install wright via the PPA [sometimesfood/wright][ppa]:

    sudo apt-get install software-properties-common
    sudo add-apt-repository -y ppa:sometimesfood/wright
    sudo apt-get update && sudo apt-get install wright

If you use a Debian-based distribution that is not Ubuntu, you have to
update your apt sources manually before installing wright:

    export DISTRO="$(lsb_release -sc)"
    export PPA_LIST="sometimesfood-wright-${DISTRO}.list"
    sudo sed -i "s/${DISTRO}/trusty/g" /etc/apt/sources.list.d/${PPA_LIST}

[ppa]: http://launchpad.net/~sometimesfood/+archive/ubuntu/wright

Documentation
-------------

There is not too much useful documentation that is targeted towards
users at the moment.

Run `bundle exec yard` to generate
[HTML docs for wright developers](http://rubydoc.info/gems/wright/).

Contributing
------------

Contributions to wright are greatly appreciated. If you would like to
contribute to wright, please have a look at the
[contribution guidelines](CONTRIBUTING.md).

To start hacking on wright, simply install the development
dependencies via bundler:

 - `bundle install --path .bundle`
 - `bundle exec rake test`

All tests should pass.

Copyright
---------

Copyright (c) 2012-2015 Sebastian Boehm. See [LICENSE](LICENSE) for
details.
