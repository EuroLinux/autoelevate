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
    libvirt.graphics_type = "spice"
    libvirt.channel :type => 'spicevmc', :target_name => 'com.redhat.spice.0', :target_type => 'virtio'
    libvirt.redirdev :type => "spicevmc"
    libvirt.uri = 'qemu:///system'
  end
end
