# -*- mode: ruby -*-
# vi: set ft=ruby :
#
Vagrant.configure("2") do |config|
  # config.vm.box = "mvbcoding/awslinux"
  # amazonlinux has python dependency issues with the standard system packages
  config.vm.box = "ubuntu/xenial64"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = "4"
  end

  config.vm.provision "file",
    source: "Dockerfile",
    destination: "/tmp/Dockerfile"
  config.vm.provision "file",
    source: "playbook.yml",
    destination: "/tmp/playbook.yml"

  config.vm.provision "shell", inline: <<-SHELL
    mkdir -p /etc/ansible
    mv /tmp/Dockerfile /etc/ansible
    mv /tmp/playbook.yml /etc/ansible

    apt-get update
    apt-get install -y python-setuptools python-pip
    pip install ansible

    # this part will take a while...
    ansible-playbook -c local -i "localhost," /etc/ansible/playbook.yml
  SHELL
end
