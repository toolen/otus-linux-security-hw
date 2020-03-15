# -*- mode: ruby -*-
# vi: set ft=ruby :

class SnykToken
  def to_s
      print "SNYK_TOKEN: "
      STDIN.gets.chomp
  end
end

Vagrant.configure("2") do |config|

  IP="192.168.55.11"

  config.vm.define "centos" do |centos|
    centos.vm.box = "centos/7"
    config.vm.box_version = "1905.1"
    centos.vm.network "private_network", ip: IP
    centos.vm.synced_folder ".", "/vagrant", type: "rsync"
    centos.vm.provision "shell", path: "centos-provision.sh", env: {
      "SNYK_TOKEN" => SnykToken.new,
      "IP" => IP
    }

    path_to_vdi = "./sata1.vdi"
    centos.vm.provider "virtualbox" do |vb|
      unless File.exist?(path_to_vdi)
        vb.customize ["createhd", "--filename", path_to_vdi, "--size", 10 * 1024]
        vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata"]
      end  
      vb.customize ["storageattach", :id, "--storagectl", "SATA", "--port", 1, "--device", 0, "--type", "hdd", "--medium",  path_to_vdi]
    end

  end

end
