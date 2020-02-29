# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.define "ubuntu", primary: true do |ubuntu|
    ubuntu.vm.box = "ubuntu/xenial64"
    ubuntu.vm.box_version = "20160319.0.0"
    ubuntu.vm.provision "shell", path: "ubuntu-provision.sh"
  end

  config.vm.define "centos" do |centos|
    centos.vm.box = "centos/7"
    centos.vm.box_version = "1505.01"
    centos.vm.synced_folder ".", "/vagrant", type: "rsync"
    centos.vm.provision "shell", path: "centos-provision.sh"
  end

end
