# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.provision "shell", path: "provision.sh"
  config.vm.provider "virtualbox" do |vb|
    path_to_vdi = "./sata1.vdi"
    unless File.exist?(path_to_vdi)
      vb.customize ["createhd", "--filename", path_to_vdi, "--size", 10 * 1024]
      vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata"]
    end  
    vb.customize ["storageattach", :id, "--storagectl", "SATA", "--port", 1, "--device", 0, "--type", "hdd", "--medium",  path_to_vdi]
  end

end
