# autoelevate

Automatically ELevate your Enterprise Linux 7 to Enterprise Linux 8

## Support

The following distributions are supported on the x86_64 architecture:

- CentOS 7
- EuroLinux 7
- Red Hat Enterprise Linux 7

## Usage

An example that ELevates a supported system to EuroLinux 8:

```
./autoelevate.sh -d eurolinux
```

If you want to ELevate to another distribution, replace `eurolinux` with the distribution of your choice.

## Preparations

Please make sure that the system you're ELevating from is up to date.

The script covers the basics of several Enterprise Linux installations, but it can't possibly cover every existing non-standard configuration out there.
Extra precautions have been arranged, but there's always the risk of something going wrong in the process and users are always recommended to make a backup.

### SSH root login

Make sure that you do not login to your machine as root via SSH. If that's the case, create another identity and use it to login. Then after the migration process is complete, you can enable root login again and delete that identity.

### VMware SCSI disk device

Remove an existing SCSI disk device in the VMware virtual machine settings.

Next, please add an IDE device and point it to an existing virtual disk that was used by the virtual machine - usually this will be the file '\<virtual machine name\>.vmdk'.

After the migration is done and the system boots, you can optionally change the disk device type back to SCSI (or NVMe, which is recommended by VMware software for Enterprise Linux 8).


## Troubleshooting

### "Entering emergency mode" after 'upgrade' initramfs

After a successful upgrade, you might get an emergency shell. This is harmless - just reboot your machine.

### SELinux has been disabled

The script will disable SELinux - this is required for a successful upgrade.

Please don't turn it back on. Otherwise you might encounter login issues.
