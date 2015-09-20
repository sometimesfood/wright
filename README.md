wright
======
[![Gem Version](https://img.shields.io/gem/v/wright.svg?style=flat-square)][gem]
[![Build Status](https://img.shields.io/travis/sometimesfood/wright.svg?style=flat-square)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/sometimesfood/wright.svg?style=flat-square)][codeclimate]
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/sometimesfood/wright.svg?style=flat-square)][codeclimate]
[![Gem Dependencies](https://img.shields.io/gemnasium/sometimesfood/wright.svg?style=flat-square)][gemnasium]

Lightweight configuration management.

Getting Started
---------------
Performing simple administrative tasks with wright is easy.

```ruby
#!/usr/bin/env wright

package 'sudo'

file '/etc/sudoers.d/env_keep-editor',
     content: "Defaults env_keep += EDITOR\n",
     owner:   'root:root',
     mode:    '440'
```

Scripts can also be run directly from the shell.

    wright -e "package 'tmux'"

If you would rather see the effects of running a wright script first,
use the dry-run option:

    wright --dry-run -e "package 'tmux'"

For a list of command-line parameters, see
[the manpage][wright-manpage]. For a more in-depth list of tasks you
can perform using wright, check the [resource list][wright-resources].

Installation
------------
Since wright does not have any runtime dependencies apart from Ruby
≥1.9, it can safely be installed system-wide via rubygems:

    sudo gem install wright

Installation on Debian-based systems
------------------------------------
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

Documentation
-------------
As a wright user, the following documents are probably going to be of
interest to you:

- [wright manpage][wright-manpage]
- [list of wright resources][wright-resources]
- [wright is just Ruby][wright-is-ruby]
- [list of supported platforms][wright-platforms]

As a wright developer, you might also be interested in the
[wright developer docs](http://www.rubydoc.info/gems/wright/) which
can be generated via `bundle exec yard`.

Contributing
------------
Contributions to wright are greatly appreciated. If you would like to
contribute to wright, please have a look at the
[contribution guidelines](CONTRIBUTING.md).

Copyright
---------
Copyright (c) 2012-2015 Sebastian Boehm. See [LICENSE](LICENSE) for
details.

[gem]: https://rubygems.org/gems/wright
[travis]: https://travis-ci.org/sometimesfood/wright
[codeclimate]: https://codeclimate.com/github/sometimesfood/wright
[gemnasium]: https://gemnasium.com/sometimesfood/wright
[ppa]: http://launchpad.net/~sometimesfood/+archive/ubuntu/wright
[wright-manpage]: http://wright.sometimesfood.org/man/wright.1.html
[wright-resources]: http://wright.sometimesfood.org/doc/resources.html
[wright-is-ruby]: http://wright.sometimesfood.org/doc/wright-is-ruby.html
[wright-platforms]: http://wright.sometimesfood.org/doc/supported-platforms.html
