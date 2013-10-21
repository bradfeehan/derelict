# Derelict

[![Build Status](https://travis-ci.org/bradfeehan/derelict.png?branch=master)](https://travis-ci.org/bradfeehan/derelict)
[![Code Climate](https://codeclimate.com/github/bradfeehan/derelict.png)](https://codeclimate.com/github/bradfeehan/derelict)

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


## Usage

Some examples of common operations using Derelict:

```ruby
require "derelict"

# Determine if there's a "default" VM defined in /path/to/project
Derelict.instance.connect("/path/to/project").vm(:default).exists?
```

### Advanced

```ruby
require "derelict"

# Create an instance (represents a Vagrant installation)
instance = Derelict.instance("/path/to/vagrant")
instance = Derelict.instance # Defaults to /Applications/Vagrant

# Issue commands to the instance directly (not usually necessary)
result = instance.execute('--version') # Shell::Executer object
print "success" if result.success?     # if Vagrant's exit status was 0
print result.stdout                    # "Vagrant 1.3.3\n"

# Connect to a Vagrant project (containing a Vagrantfile)
connection = instance.connect("/path/to/project")

# Issue commands to the connection directly (runs from the project dir)
result = connection.execute(:up) # runs "vagrant up" in project dir
result.success?                  # it's a Shell::Executer object again

# Retrieve a particular VM from a connection (multi-machine support)
vm = connection.vm(:web) # "vm" is a Derelict::VirtualMachine
vm.exists?               # does the connection define a "web" VM?
vm.state                 # current VM state (:running, :not_created...)
vm.running?              # whether the VM is currently running or not
vm.up!                   # runs "vagrant up" for this VM only
vm.halt!                 # runs "vagrant halt" for this VM only
vm.destroy!              # runs "vagrant destroy --force" for this VM
vm.reload!               # runs "vagrant reload" for this VM only
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
