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
    echo "You must run the script as root."
    exit 1
}

autoelevate() {
  # Grab CentOS GPG keys
  echo "Grabbing CentOS 7 GPG keys..."
  curl "https://vault.centos.org/RPM-GPG-KEY-CentOS-7" > "/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7" && \

  # Make sure CentOS Extras repo is available
  echo "Making sure CentOS Extras repo is available..."
  cat > "/etc/yum.repos.d/autoelevate-centos-extras.repo" <<-'EOF'
[autoelevate-centos-7-extras]
name=AutoELevate - CentOS 7 Extras
baseurl=http://mirror.centos.org/centos/7/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

  # Add CentOS Base repo for unregistered systems behind paywalls
  if [ $(which subscription-manager) ]; then
    echo "This system has subscription-manager installed. Checking for consumed subscriptions..."
    if [ "$(subscription-manager list --consumed | grep 'No consumed subscription pools were found' )"  ] ; then
      echo "This system is not registered. Adding CentOS 7 Base repo for AutoELevate..."
      cat > "/etc/yum.repos.d/autoelevate-centos-base.repo" <<-'EOF'
[autoelevate-centos-7-base]
name=AutoELevate - CentOS 7 Base
baseurl=http://mirror.centos.org/centos/7/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
    fi
  fi

  # First stage
  yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el7.noarch.rpm && \
  yum install -y leapp-upgrade "leapp-data-${distro}" && \
  leapp preupgrade || \
  echo "Moving on with AutoELevate..." && \
  rmmod pata_acpi floppy mptbase mptscsih mptspi || true && \
  echo PermitRootLogin no | tee -a /etc/ssh/sshd_config && \
  sed -i 's@PermitRootLogin yes@PermitRootLogin no@g' /etc/ssh/sshd_config && \
  leapp answer --section remove_pam_pkcs11_module_check.confirm=True && \
  leapp upgrade && \
  reboot
  # Second stage will continue after reboot
}

while getopts "d:" option; do
    case "$option" in
        d) distro="$OPTARG" ;;
        *) usage ;;
    esac
done
if [[ "${valid_distros[*]}" =~ "${distro}" ]] && \
   [[ "$(rpm --eval %dist)" =~ ".el7" ]] && \
   [ "$(id -u)" -eq 0 ]; then
  autoelevate
else
  usage
fi
