VAGRANTFILE_API_VERSION="2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"

  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/"+
                      "precise-server-cloudimg-amd64-vagrant-disk1.box"

  config.omnibus.chef_version = "11.6.2"

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "vendor/cookbooks"
    chef.add_recipe "demo::default"
  end
end
