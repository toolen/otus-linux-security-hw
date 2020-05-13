# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # config.vm.define "attacker", primary: true do |attacker|
  #   attacker.vm.box = "centos/7"
  #   attacker.vm.hostname = "attacker.dev"
  #   attacker.vm.network "private_network", ip: "192.168.0.100"
  # end

  config.vm.define "snort" do |snort|
    snort.vm.box = "centos/7"
    snort.vm.hostname = "snort.dev"
    snort.vm.network "private_network", ip: "192.168.0.200"
    snort.vm.provision "shell", path: "secure-provision.sh"
  end

end
