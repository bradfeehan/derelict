# Derelict

Provides a Ruby API to control [Vagrant][1] where Vagrant is installed
via the Installer package on Mac OS X.

Currently a work-in-progress.

[1]: <https://www.vagrantup.com>


## Why?

Vagrant was historically available as a [gem][2], naturally providing a
Ruby API to control Vagrant in other Ruby libraries and applications.
However, [since version 1.1.0][3], [Vagrant is distributed exclusively
using an Installer package][4]. Derelict is a Ruby library that wraps
the Vagrant binary, shelling out and parsing the results of each
command.

[2]: <https://rubygems.org>
[3]: <https://groups.google.com/forum/#!msg/vagrant-up/kX_wvn7wcds/luwNur4kgDEJ>
[4]: <http://mitchellh.com/abandoning-rubygems>


## Installation

Add this line to your application's Gemfile:

    gem "derelict"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install derelict


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
