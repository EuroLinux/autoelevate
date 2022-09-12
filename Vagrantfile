# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "eurolinux-vagrant/centos-7"
  config.vm.hostname = "centos7-elevate"
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
  config.vm.provider "libvirt" do |libvirt|
    libvirt.cpus = 1
    libvirt.memory = 2048
    libvirt.random_hostname = true
    libvirt.uri = 'qemu:///system'
  end
end
