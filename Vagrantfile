# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.define "attacker", primary: true do |attacker|
    attacker.vm.box = "kalilinux/rolling"
    attacker.vm.hostname = "attacker.dev"
    attacker.vm.network "private_network", ip: "192.168.0.100"
  end

  config.vm.define "secure" do |secure|
    secure.vm.box = "centos/7"
    secure.vm.hostname = "secure.dev"
    secure.vm.network "private_network", ip: "192.168.0.200"
  end

end
