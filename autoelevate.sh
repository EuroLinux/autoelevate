#!/bin/bash

usage() {
    echo "Usage: ${0##*/} [OPTIONS]"
    echo
    echo "OPTIONS"
    echo "-d      Distribution to migrate to"
    echo ""
    echo "Valid distributions are:"
    echo "almalinux"
    echo "centos"
    echo "eurolinux"
    echo "oraclelinux"
    echo "rocky"
    exit 1
}

while getopts "d:" option; do
    case "$option" in
        d) distro="$OPTARG" ;;
        *) usage ;;
    esac
done

sudo yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el7.noarch.rpm
sudo yum install -y leapp-upgrade "leapp-data-${distro}"
sudo leapp preupgrade
sudo rmmod pata_acpi floppy mptbase mptscsih mptspi
echo PermitRootLogin no | sudo tee -a /etc/ssh/sshd_config
sudo sed -i 's@PermitRootLogin yes@PermitRootLogin no@g' /etc/ssh/sshd_config
sudo leapp answer --section remove_pam_pkcs11_module_check.confirm=True
sudo leapp upgrade
sudo reboot
