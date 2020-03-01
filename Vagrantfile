# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "centos" do |subconfig|
   subconfig.vm.box = "centos/7"
   subconfig.vm.network "private_network", ip: "192.168.55.11"
   subconfig.vm.provider "virtualbox" do |vb|
     vb.memory = "256"
     vb.cpus = "1"
     unless File.exist?('./sata1.vdi')
        vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
        vb.customize ['createhd', '--filename', './sata1.vdi', '--size', 500 * 1024]
     end  
     vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium',  './sata1.vdi']
   end
   subconfig.vm.provision "shell", path: "centos-provision.sh"
  end
 
  # config.vm.define "ubuntu" do |subconfig|
  #  subconfig.vm.box = "ubuntu/bionic64"
  #  subconfig.vm.hostname="ubuntu"
  #  subconfig.vm.network :private_network, ip: "192.168.55.12"
  #  subconfig.vm.provider "virtualbox" do |vb|
  #    vb.memory = "256"
  #    vb.cpus = "1"
  #  end
  # end
 
 #config.vm.define "kali" do |subconfig|
 #  subconfig.vm.box = "offensive-security/kali-linux"
 #  config.vm.box_version = "2019.1.0"
 #  subconfig.vm.hostname="kali"
 #  subconfig.vm.network :private_network, ip: "192.168.55.13"
 #  subconfig.vm.provider "virtualbox" do |vb|
 #    vb.memory = "256"
 #    vb.cpus = "1"
 #  end
 # end
 
 end 
