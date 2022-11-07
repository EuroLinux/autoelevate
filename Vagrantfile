# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box_check_update = true
  config.vm.provider "libvirt" do |libvirt|
    libvirt.cpus = 1
    libvirt.memory = 2048
    libvirt.random_hostname = true
    libvirt.uri = 'qemu:///system'
  end

  config.vm.define "centos7" do |i|
    i.vm.box = "eurolinux-vagrant/centos-7"
    i.vm.hostname = "centos7"
  end

  config.vm.define "generic-rhel7" do |i|
    i.vm.box = "generic/rhel7"
    i.vm.hostname = "generic-rhel7"
    i.vm.hostname = "rhel7"
  end

  config.vm.define "eurolinux7" do |i|
    i.vm.box = "eurolinux-vagrant/eurolinux-7"
    i.vm.hostname = "eurolinux7"
  end

  config.vm.define "scientific7" do |i|
    i.vm.box = "eurolinux-vagrant/scientific-linux-7"
    i.vm.hostname = "scientific7"
  end

  config.vm.define "oracle7" do |i|
    i.vm.box = "eurolinux-vagrant/oracle-linux-7"
    i.vm.hostname = "oracle7"
  end

end

end
