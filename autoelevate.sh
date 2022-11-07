#!/bin/bash

distro="invalid"
valid_distros=( "almalinux" "centos" "eurolinux" "oraclelinux" "rocky" )

usage() {
    echo "Usage: ${0##*/} [OPTIONS]"
    echo
    echo "OPTIONS"
    echo "-d      Distribution to migrate to"
    echo ""
    echo "Valid distributions are: ${valid_distros[@]}"
    exit 1
}

autoelevate() {
  # Make sure CentOS Extras repo is available
  curl "https://vault.centos.org/RPM-GPG-KEY-CentOS-7" > "/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7"
  cat > "autoelevate-centos-extras.repo" <<-'EOF'
[autoelevate-centos-7-extras]
name=AutoELevate - CentOS 7 Extras
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

  # First stage
  sudo yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el7.noarch.rpm && \
  sudo yum install -y leapp-upgrade "leapp-data-${distro}" && \
  sudo leapp preupgrade || \
  echo "Moving on with AutoELevate..." && \
  sudo rmmod pata_acpi floppy mptbase mptscsih mptspi && \
  echo PermitRootLogin no | sudo tee -a /etc/ssh/sshd_config && \
  sudo sed -i 's@PermitRootLogin yes@PermitRootLogin no@g' /etc/ssh/sshd_config && \
  sudo leapp answer --section remove_pam_pkcs11_module_check.confirm=True && \
  sudo leapp upgrade && \
  sudo reboot
  # Second stage will continue after reboot
}

while getopts "d:" option; do
    case "$option" in
        d) distro="$OPTARG" ;;
        *) usage ;;
    esac
done
if [[ "${valid_distros[*]}" =~ "${distro}" ]] && [[ "$(rpm --eval %dist)" =~ ".el7" ]]; then
  autoelevate
else
  usage
fi
