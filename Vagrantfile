# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "ossim", primary: true do |ossim|
    ossim.vm.box = "debian/buster64"
    ossim.vm.hostname = "ossim.dev"
    ossim.vm.network "public_network", bridge: "wlp3s0"
    ossim.vm.network "private_network", ip: "192.168.2.100"
  end

  config.vm.define "msf" do |msf|
    msf.vm.box = "rapid7/metasploitable3-ub1404"
    msf.vm.hostname = "msf.dev"
    msf.vm.network "private_network", ip: "192.168.2.200"
  end
end
