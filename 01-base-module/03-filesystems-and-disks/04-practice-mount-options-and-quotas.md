# Практика 4

Цель: выполнить требования и задачи.

# Требования и задачи

1. Опции монтирования.
  - настройте разные точки монтирования с опциями:
    - `ro(read-only)`
      - добавляем `ro` в настройки монтирования `/etc/fstab`, например, первого раздела первого диска (на нем ext4)
        ```
        # bind disk1.img partitions
        /home/yawkar/trash/disk1.img /mnt/disk1p1 ext4 loop,offset=1048576,sizelimit=1072693248,ro,nofail 0 0
        ```
    - `sync`
      - добавляем `sync` в настройки маунта первого раздела второго диска (настройка заставляет все изменения в файловой системе быть синхронными и не зависит от файловой системы раздела)
        ```
        # bind disk2.img partitions
        /home/yawkar/trash/disk2.img /mnt/disk2p1 xfs loop,offset=1048576,sizelimit=524288000,sync,nofail 0 0
        /home/yawkar/trash/disk2.img /mnt/disk2p2 btrfs loop,offset=525336576,sizelimit=524288000,nofail 0 0
        ```
    - `noexec`
      - добавляем `noexec` в настройки маунта первого раздела третьего диска (настройка запрещает прямое исполнение файлов в этой фс)
        ```
        # bind disk3.img partitions
        /home/yawkar/trash/disk3.img /mnt/disk3p1 ext4 loop,offset=1048576,sizelimit=165675008,noexec,nofail 0 0
        /home/yawkar/trash/disk3.img /mnt/disk3p2 btrfs loop,offset=166723584,sizelimit=165675008,nofail 0 0
        /home/yawkar/trash/disk3.img /mnt/disk3p3 ext4 loop,offset=332398592,sizelimit=165675008,nofail 0 0
        /home/yawkar/trash/disk3.img /mnt/disk3p4 xfs loop,offset=498073600,sizelimit=367001600,nofail 0 0
        ```
    - `reboot`
    - проверяем в `systemctl status mnt-disk*`, все окей
2. Настройка квот.
  - включите поддержку квот на одном из дисков
    - `sudo apt update && sudo apt upgrade`
    - `sudo apt install quota`
    - `sudo umount /mnt/disk3p3`
    - `sudo losetup --find --partscan --show ~/trash/disk3.img`
      - `/dev/loop0`
    - `sudo tune2fs -O quota /dev/loop0p3`
    - `reboot`
    - `lsblk`, чтобы найти девайс
    - `sudo dumpe2fs /dev/loop5 | grep quota`, видим что фича на fs включена
    - `sudo quotaon /mnt/disk3p3`, включаем quota enforcement, изначально включен только quota accounting
    - `sudo quotaon -vug /mnt/disk3p3`, включаем пользовательские и групповые квоты
  - создайте пользователей и назначьте им квоты
    - `sudo edquota yawkar -f /dev/loop5`, выдам своему пользователю 5000 hard limit на inodes и блоки памяти
    - `quota -v yawkar`, проверяем, что квоты были выставлены, вижу
      ```
      Disk quotas for user yawkar (uid 1000):
           Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
           /dev/loop5       0       0    5000               0       0    5000
      ```
    - создадим группу тех, кто может пользоваться этой фс
      - `sudo addgroup users-of-disk3p3`
      - `sudo adduser yawkar users-of-disk3p3`
      - `sudo umount /mnt/disk3*`, чтобы chgrp у фс до маунта
      - `sudo losetup --find --partscan --show ~/trash/disk3.img`
        - `/dev/loop3`
      - `sudo chgrp users-of-disk3p3 /dev/loop3p3 -R && sudo chmod 777 -R /dev/loop3p3`
      - `reboot`
      - `sudo chmod 777 -R /mnt/disk3p3`
      - `reboot`
      - `touch /mnt/disk3p3/lol.txt`, можем создавать файлы!

