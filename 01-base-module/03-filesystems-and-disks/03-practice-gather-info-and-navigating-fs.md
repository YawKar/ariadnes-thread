# Практика 3

Цель: выполнить требования и задачи.

# Требования и задачи

1. Просмотр информации о месте.
  - Выполните `df -h` для анализа свободного и занятого пространства.
    - `df -h`, может возникнуть ситуация, когда места достаточно, а файл не создается, тогда вероятно достигнут лимит inodes, если речь про ext4,
      можно проверить `df -ih` и затем решать эту проблему например так:
      1. бекапиться и пересоздавать фс с указанием большего числа inode, затем восстановить файлы из бекапа
      2. закинуть файлы в uncompressed tar архив/виртуальный диск (под рутом должны быть reserved inodes доступны), чтобы освободить inode'ы, и этот tar архив/виртуальный диск маунтить как отдельную фс
      3. удалять ненужные файлы :D
      ```
      Filesystem      Size  Used Avail Use% Mounted on
      tmpfs           741M  1.9M  739M   1% /run
      /dev/vda2        62G   12G   47G  21% /
      tmpfs           3.7G     0  3.7G   0% /dev/shm
      efivarfs        256K   31K  226K  12% /sys/firmware/efi/efivars
      tmpfs           5.0M  8.0K  5.0M   1% /run/lock
      tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
      tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-udev-load-credentials.service
      tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-sysctl.service
      tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-tmpfiles-setup-dev-early.service
      tmpfs           3.7G   16K  3.7G   1% /tmp
      tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-tmpfiles-setup-dev.service
      /dev/vda1       1.1G  6.4M  1.1G   1% /boot/efi
      /dev/loop1      989M  276K  921M   1% /mnt/disk1p1
      /dev/loop4      132M  152K  121M   1% /mnt/disk3p3
      /dev/loop2      500M  5.8M  419M   2% /mnt/disk2p2
      /dev/loop3      132M  152K  128M   1% /mnt/disk3p1
      /dev/loop5      158M  5.8M   77M   7% /mnt/disk3p2
      /dev/loop0      436M   34M  403M   8% /mnt/disk2p1
      /dev/loop6      286M   24M  263M   9% /mnt/disk3p4
      tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-tmpfiles-setup.service
      tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
      share           461G  247G  214G  54% /mnt/utm
      /mnt/utm        461G  247G  214G  54% /home/yawkar/utm
      tmpfs           1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyAMA0.service
      tmpfs           741M  112K  741M   1% /run/user/1000
      ```
  - Создайте несколько крупных файлов и найдите их с помощью du
    - В предыдущих практиках мы уже создавали виртуальные диски размером в 1G, вот их поищу
    - Ахаха, сделал `du -ha` в папке с дисками, вижу, что они не 1G занимают физического пространства, а только 18M, 93M & 587M, почитал, похоже из-за того, что это sparse файлы, но у `du` есть флажок `--apparent-size`, который заставляет его учитывать логический размер файлов, поэтому его заиспользую
    - `cd ~ && du -ha --apparent-size -t 1G -B 1M | sort -n` (`-t`: threshold, задаю минимальный размер для учитывания; `-B`: задаю единицу исчисления 1 мегабайт; `sort -n`: сортирую численно)
      ```
      1024	./trash/disk1.img
      1024	./trash/disk2.img
      1024	./trash/disk3.img
      3073	./trash
      3149	.
      ```
2. Поиск больших файлов.
  - Установите и используйте ncdu для анализа использования пространства.
    - `sudo apt install ncdu`
    - `ncdu`, приятный TUI для просмотра пространства
3. Состояние SMART-дисков
  - Проверьте состояние дисков с помощью smartctl
    - `sudo apt install smartmontools`
    - так как у меня виртуалка, то она походу не эмулирует те вызовы, которые использует smartctl, чтобы диагностировать всякое разное

