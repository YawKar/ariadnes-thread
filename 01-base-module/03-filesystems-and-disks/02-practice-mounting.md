# Практика 2

Цель: выполнить требования и задачи.

# Требования и задачи

1. Ручное монтирование.
  - смонтируйте созданные 3 диска в директории `/mnt/diskX` (X in [1, 2, 3])
    - `sudo mkdir /mnt/disk1p1`
    - `sudo mkdir /mnt/disk2p{1..2}`
    - `sudo mkdir /mnt/disk3p{1..4}`
    - `sudo losetup --find --partscan --show disk1.img`
      - `/dev/loop18`
      - заметил, что я видать что-то сделал с disk1.img, на нем не было разделов, по-быстрому создал раздел на весь диск и ext4
        - `sudo losetup -d /dev/loop18`
        - `fdisk disk1.img`, `n`, `p`, дефолты, `w`
        - `sudo losetup --find --partscan --show disk1.img`
        - `sudo mkfs.ext4 /dev/loop18p1`
    - `mount /dev/loop18p1 /mnt/disk1p1`
    - `sudo losetup --find --partscan --show disk2.img`
      - `/dev/loop19`
    - `mount /dev/loop19p1 /mnt/disk2p1`
    - `mount /dev/loop19p2 /mnt/disk2p2`
    - `sudo losetup --find --partscan --show disk3.img`
      - `/dev/loop20`
    - `mount /dev/loop20p1 /mnt/disk3p1`
    - `mount /dev/loop20p2 /mnt/disk3p2`
    - `mount /dev/loop20p3 /mnt/disk3p3`
    - `mount /dev/loop20p4 /mnt/disk3p4`
  - проверяем `lsblk | grep /mnt`
    ```
    └─loop18p1 259:6    0  1023M  0 part /mnt/disk1p1
    ├─loop19p1 259:0    0   500M  0 part /mnt/disk2p1
    └─loop19p2 259:1    0   500M  0 part /mnt/disk2p2
    ├─loop20p1 259:2    0   158M  0 part /mnt/disk3p1
    ├─loop20p2 259:3    0   158M  0 part /mnt/disk3p2
    ├─loop20p3 259:4    0   158M  0 part /mnt/disk3p3
    └─loop20p4 259:5    0   350M  0 part /mnt/disk3p4
    ```
  - проверяем `df -h | grep /mnt`
    (share & /mnt/utm -- это между хостом и гостевой машинкой shared folder)
    ```
    share           461G  247G  214G  54% /mnt/utm
    /mnt/utm        461G  247G  214G  54% /home/yawkar/utm
    /dev/loop18p1   989M  276K  921M   1% /mnt/disk1p1
    /dev/loop19p1   436M   34M  403M   8% /mnt/disk2p1
    /dev/loop19p2   500M  5.8M  419M   2% /mnt/disk2p2
    /dev/loop20p1   132M  152K  128M   1% /mnt/disk3p1
    /dev/loop20p2   158M  5.8M   77M   7% /mnt/disk3p2
    /dev/loop20p3   132M  152K  121M   1% /mnt/disk3p3
    /dev/loop20p4   286M   24M  263M   9% /mnt/disk3p4
    ```
2. Автоматическое монтирование разделов всех виртуальных дисков при [ре]буте.
  - что нам надо: чтобы какой-то сервис при буте замаунтил нам из diskX.img все разделы в /mnt/diskXpY
  - что умеет маунтить на стартапе: у `systemd` есть генератор, который читает `/etc/fstab` и генерирует `*.mount` unit'ы, которые маунтят то шо нам надо
    - отсюда решение: добавить в `/etc/fstab` строчки под каждый раздел
  - вопросы и ответы:
    - как нам указать `mount`, что нужно использовать loop device?
      - у него есть опция `loop`, которая говорит, чтобы `mount` сам нашел свободное устройство и заюзал его
    - можно ли заставить `mount` просканировать таблицу разделов, чтобы он сам там нафигачил папок?
      - `man mount` показывает, что у него есть такие опции
        (UPD: они работают ток для уже подключенных `/dev/<disk-or-partition>`, не совсем наш кейс, можно, конечно, поднять unit, который будет через `losetup` создавать loop девайсы и уже их доставать по их UUID):
        - `label`: маунтит раздел с данным лейблом фс
        - `uuid`: маунтит раздел с данным UUID
        - `PARTLABEL=`: маунтит раздел с данным label раздела (GPT поддерживает)
        - `PARTUUID=`: маунтит раздел с данным UUID раздела (GPT поддерживает)
      - есть еще `offset`, `sizelimit`, позволяющие задать начало и размер раздела для подгрузки с `loop`
        - достаем наши START/END секторы и переводим их в байты через `parted diskX.img`, `unit B`, `print`
        - `disk1.img`:
          ```
          Number  Start     End          Size         Type     File system  Flags
           1      1048576B  1073741823B  1072693248B  primary  ext4
          ```
        - `disk2.img`:
          ```
          Number  Start       End          Size        File system  Name  Flags
           1      1048576B    525336575B   524288000B  xfs
           2      525336576B  1049624575B  524288000B  btrfs
          ```
        - `disk3.img`:
          ```
          Number  Start       End         Size        File system  Name     Flags
           1      1048576B    166723583B  165675008B  ext4         primary
           2      166723584B  332398591B  165675008B  btrfs        primary
           3      332398592B  498073599B  165675008B  ext4         primary
           4      498073600B  865075199B  367001600B  xfs          primary
          ```
  - добавляем в `/etc/fstab`:
    ```
    # bind disk1.img partitions
    /home/yawkar/trash/disk1.img /mnt/disk1p1 ext4 loop,offset=1048576,sizelimit=1072693248,nofail 0 0

    # bind disk2.img partitions
    /home/yawkar/trash/disk2.img /mnt/disk2p1 xfs loop,offset=1048576,sizelimit=524288000,nofail 0 0
    /home/yawkar/trash/disk2.img /mnt/disk2p2 btrfs loop,offset=525336576,sizelimit=524288000,nofail 0 0

    # bind disk3.img partitions
    /home/yawkar/trash/disk3.img /mnt/disk3p1 ext4 loop,offset=1048576,sizelimit=165675008,nofail 0 0
    /home/yawkar/trash/disk3.img /mnt/disk3p2 btrfs loop,offset=166723584,sizelimit=165675008,nofail 0 0
    /home/yawkar/trash/disk3.img /mnt/disk3p3 ext4 loop,offset=332398592,sizelimit=165675008,nofail 0 0
    /home/yawkar/trash/disk3.img /mnt/disk3p4 xfs loop,offset=498073600,sizelimit=367001600,nofail 0 0
    ```
  - `reboot`
  - проверяем `systemctl status mnt-disk* | grep "active (mounted)" | wc`, видим 7, собственно, это количество наших разделов
    ну и в `lsblk` тоже видим их

