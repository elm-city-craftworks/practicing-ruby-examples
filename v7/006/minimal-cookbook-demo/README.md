Demo Cookbook
========================

This Chef cookbook is a code sample from Issue 7.6 of Practicing Ruby. It installs 
Ruby 2.0, updates RubyGems to the latest version, and then installs the 
Bundler gem. It makes use of the [ruby_build][] cookbook to do 
its heavy lifting.

## Requirements

To use this cookbook, you need the following software:

* [VirtualBox] - Version 4.2 or higher
* [Vagrant] - Version 1.3.4 or higher
* [vagrant-omnibus] - installable via `vagrant plugin install vagrant-omnibus`
* [Berkshelf] - installable via `bundle install`

When you provision a VM using this cookbook, Chef will be installed for you 
via `vagrant-omnibus`, and if necessary an Ubuntu Linux base system image will 
be downloaded automatically. See the project's `Vagrantfile` for exact 
versions used.

## Provisioning

Run the following two commands inside the cookbook to create a vagrant box and boot it up:

    $ bundle exec berks install --path vendor/cookbooks
    $ vagrant up --provision

In case the VM is already up, you can always run Chef again with:

    $ bundle exec berks install --path vendor/cookbooks
    $ vagrant provision

To SSH into the running VM:

    $ vagrant ssh

You can verify the Ruby, RubyGems, and Bundler versions with the following commands:

    $ ruby -v
    $ gem -v
    $ bundle -v

Last but not least, here is how to stop and destroy the VM when you no longer
need it or when you want to start from scratch:

    $ vagrant destroy -f

[ruby_build]: https://github.com/fnichol/chef-ruby_build
[Berkshelf]: http://berkshelf.com/
[Vagrant]: http://vagrantup.com
[VirtualBox]: https://www.virtualbox.org/
[practicingruby-web]: https://github.com/elm-city-craftworks/practicing-ruby-web
[vagrant-omnibus]: https://github.com/schisamo/vagrant-omnibus
