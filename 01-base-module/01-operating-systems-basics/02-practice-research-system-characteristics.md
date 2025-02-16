# Practice 2

Goals:
  - [x] Find kernel version
    - using `uname -r` find the kernel release: `6.11.0-14-generic`
  - [x] Find available/used memory (Random-Access Memory & Solid-State Drive memory)
    - RAM:
      - using `free -h`
        ```
                       total        used        free      shared  buff/cache   available
        Mem:           7.2Gi       1.1Gi       5.2Gi        75Mi       1.1Gi       6.1Gi
        Swap:          4.0Gi          0B       4.0Gi
        ```
    - SSD:
      - using `df -h`
        ```
        Filesystem      Size  Used Avail Use% Mounted on
        tmpfs           741M  1.9M  739M   1% /run
        /dev/vda2        62G  9.6G   49G  17% /
        tmpfs           3.7G     0  3.7G   0% /dev/shm
        efivarfs        256K   26K  231K  10% /sys/firmware/efi/efivars
        tmpfs           5.0M  8.0K  5.0M   1% /run/lock
        tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
        tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-udev-load-credentials.service
        tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-sysctl.service
        tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-tmpfiles-setup-dev-early.service
        tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-tmpfiles-setup-dev.service
        /dev/vda1       1.1G  6.4M  1.1G   1% /boot/efi
        tmpfs           3.7G   16K  3.7G   1% /tmp
        tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-tmpfiles-setup.service
        tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
        share           461G  258G  203G  56% /mnt/utm
        /mnt/utm        461G  258G  203G  56% /home/yawkar/utm
        tmpfs           1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyAMA0.service
        tmpfs           741M  124K  741M   1% /run/user/1000
        ```
  - [x] Find list of pre-installed packages (currently installed, because I've installed: vim, openssh-server, bindfs as well as their dependencies)
    - using `apt list --installed`
      - full list is in file [02-practice-apt-list-installed.txt](./02-practice-apt-list-installed.txt)
    - by the way `apt list --installed | wc -l` shows 1605
  - [x] Find out the boot loader type and its configuration (GRUB, EFI or etc)
    - grub 2 (`grub-install --version` shows `grub-install (GRUB) 2.12-5ubuntu5.1`)
      - `ls /boot` shows `grub` folder
      - `sudo grep grub /var/log/syslog` mentions `grub-common.service - Record successful boot for GRUB.`
      - when I changed `GRUB_TIMEOUT=-1` in `sudo vim /etc/default/grub` and then `sudo update-grub && reboot`, I started to see GRUB loader after reboot
      - however, `file -s /dev/vda1` shows `DOS/MBR boot sector` but apparently it works with GRUB
    - configuration is here: `cat /etc/default/grub` (dumped it into [02-practice-default-grub.txt](./02-practice-default-grub.txt))
  - [x] Find the last system boots logs
    - `journalctl -b 0` shows logs of the last boot (dumped it into [02-practice-journalctl-b-0.txt](./02-practice-journalctl-b-0.txt))


