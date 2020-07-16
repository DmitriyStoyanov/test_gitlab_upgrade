# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-18.04"
    config.vm.hostname = "gitlab.local.dev"

    config.vm.provider "virtualbox" do |vb|
        vb.name = "GitLab Server"
        vb.memory = "4096"
        vb.cpus = "2"
    end
    config.vm.provision "file", source: "ansible", destination: "/tmp/ansible"
    config.vm.provision "shell", path: "bootstrap.sh"
end