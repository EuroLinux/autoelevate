# autoelevate

Automatically ELevate your CentOS 7 to Enterprise Linux 8

## Usage

An example that ELevates CentOS 7 to EuroLinux 8:

```
./autoelevate.sh -d eurolinux
```

If you want to ELevate to another distribution, replace `eurolinux` with the distribution of your choice.

## Preparations

### SSH root login

Make sure that you do not login to your machine as root via SSH. If that's the case, create another identity and use it to login. Then after the migration process is complete, you can enable root login again and delete that identity.

### VMware SCSI disk device

Remove an existing SCSI disk device in the VMware virtual machine settings.

Next, please add an IDE device and point it to an existing virtual disk that was used by the virtual machine - usually this will be the file '\<virtual machine name\>.vmdk'.

After the migration is done and the system boots, you can optionally change the disk device type back to SCSI (or NVMe, which is recommended by VMware software for Enterprise Linux 8).
