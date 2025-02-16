# Пратика 2

Цели:
  - [x] Найти релизную версию ядра
    - использую `uname -r`: `6.11.0-14-generic`
  - [x] Найти доступную/используемую память (Random-Access Memory & Solid-State Drive memory)
    - RAM:
      - `free -h`
        ```
                       total        used        free      shared  buff/cache   available
        Mem:           7.2Gi       1.1Gi       5.2Gi        75Mi       1.1Gi       6.1Gi
        Swap:          4.0Gi          0B       4.0Gi
        ```
    - SSD:
      - `df -h`
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
  - [x] Найти список предустановленных пакетов (установленных на данный момент, поскольку я уже установил: vim, openssh-server, bindfs вместе с их зависимостями)
    - `apt list --installed`
      - сдампил сюда [02-practice-apt-list-installed.txt](./02-practice-apt-list-installed.txt)
    - кстати говоря, `apt list --installed | wc -l` показывает 1605
  - [x] Найти тип boot loader'а и его конфигурацию (GRUB, EFI or etc)
    - grub 2 (`grub-install --version` показывает `grub-install (GRUB) 2.12-5ubuntu5.1`)
      - `ls /boot` показывает наличие директории `grub`
      - `sudo grep grub /var/log/syslog` упоминает `grub-common.service - Record successful boot for GRUB.`
      - когда я поменял `GRUB_TIMEOUT=-1` в `sudo vim /etc/default/grub` и далее выполнил `sudo update-grub && reboot`, я начал видеть менюшку выбора того, во что хочу boot'нуться
      - однако, `file -s /dev/vda1` показывает мне `DOS/MBR boot sector`, что странно, ожидал увидеть там упоминание GRUB, но похоже GRUB работает с MBR на BIOS (не UEFI) системах
    - конфиг нашел тут: `cat /etc/default/grub` (сдампил в [02-practice-default-grub.txt](./02-practice-default-grub.txt))
  - [x] Найти логи последней загрузки системы
    - `journalctl -b 0` показал логи последнего boot'а (сдампил в [02-practice-journalctl-b-0.txt](./02-practice-journalctl-b-0.txt))


