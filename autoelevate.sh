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

check_supported_config() {
  whatprovides_distro="$(rpm -q --whatprovides /etc/redhat-release)"
  case "${whatprovides_distro}" in
    centos-release* | centos-linux-release*) ;;
    el-release*|eurolinux-release*) ;;
    *) echo "Unsupported distribution: ${whatprovides_distro}" ; exit 1 ;;
  esac

  if [ -d /sys/firmware/efi ] && [[ ! "${distro}" =~ "almalinux" ]]; then 
    echo "An EFI installation is not able to ELevate to ${distro} yet."
    exit 1
  fi

  if [[ ! "$(rpm --eval %dist)" =~ ".el7" ]]; then
    echo "Only major version 7 is qualified for ELevating."
    exit 1
  fi

  if [ "$(grep 'fips=1' /proc/cmdline)" ]; then
    echo "You appear to be running a system in FIPS mode, which is not supported for ELevate. This case requires an individual approach that can be received by contacting our technical department. Please use the medium our sales department provided after a subscription has been purchased."
    exit 1
  fi

  if grep -oq 'Secure Boot: enabled' <(bootctl 2>&1) ; then
    echo "You appear to be running a system with Secure Boot enabled, which is not yet supported for ELevate. Disable it first, then run the script again."
    exit 1
  fi
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
  if [ $(which rhn_check) ]; then
    echo "This system has rhn_check installed. Checking for consumed subscriptions..."
    rhn_check
    if [ $? -ne 0 ] ; then
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

if [[ "${valid_distros[*]}" =~ "${distro}" ]] && [ "$(id -u)" -eq 0 ]; then
  check_supported_config
  autoelevate
else
  usage
fi
