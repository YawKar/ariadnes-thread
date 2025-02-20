# Практика 1

Цель: выполнить требования и задачи.

# Требования и задачи

1. Создайте 3 виртуальных диска объемом по 1Gb.
  - `dd if=/dev/zero of=disk1.img bs=1M count=1024`
  - `dd if=/dev/zero of=disk2.img bs=1M count=1024`
  - `dd if=/dev/zero of=disk3.img bs=1M count=1024`
2. Разметьте созданные диски.
  - Разметьте `disk1.img` в формате MBR, создайте 1 раздел и отформатируйте его в `ext4`
    - `fdisk disk1.img`, дальше вводим `w<ENTER>`, чтобы автоматически создать DOS(MBR) partition table
      или можно `o<ENTER>w<ENTER>`, чтобы создать такой же partition label
    - затем создадим раздел через `n<ENTER>`, выбираем primary тип раздела `p<ENTER>` и номер раздела `1`,
      а также первый и последний сектор по умолчанию (чтобы раздел занял все место на диске)
    - `p<ENTER>` видим что все секторы за исключением 2048 первых ушли в свежий раздел типа Linux
    - `w<ENTER>` чтобы сохранить изменения
    - `mkfs.ext4 disk1.img`
    - `mkdir disk1-mounted && sudo mount -t ext4 -o loop disk1.img disk1-mounted/`
    - проверяем: `fdisk -l disk1-mounted -hT`, видим, что замаунтилось через `/dev/loop18` и тип ext4
  - Разметьте `disk2.img` в формате GPT, создайте 2 раздела: xfs, btrfs
    - `fdisk disk2.img`, `g` (GPT label), `n`, пробегаем стандартные выборы, разве что указываем последний сектор `+500M`, `w`
      делаем это дважды и получаем:
      ```
      Device       Start     End Sectors  Size Type
      disk2.img1    2048 1026047 1024000  500M Linux filesystem
      disk2.img2 1026048 2050047 1024000  500M Linux filesystem
      ```
    - теперь нам как-то надо создать /dev/XXX устройства, связанные с каждым из разделов виртуального диска
      - `sudo losetup disk2.img --find --partscan --show`
        показывает `/dev/loop18`
    - создаем xfs на первом разделе
      - `sudo apt install xfsprogs`
      - `sudo mkfs.xfs /dev/loop18p1`
    - создаем btrfs на втором разделе
      - `sudo apt install btrfs-progs`
      - `sudo mkfs.btrfs /dev/loop18p2`
    - проверяем:
      - `sudo file -s /dev/loop18p1`
        `/dev/loop18p1: SGI XFS filesystem data (blksz 4096, inosz 512, v2 dirs)`
      - `sudo file -s /dev/loop18p2`
        `/dev/loop18p2: BTRFS Filesystem sectorsize 4096, nodesize 16384, leafsize 16384, UUID=fde0f8a3-1749-47de-8ccd-3ab83b30ffad, 147456/524288000 bytes used, 1 devices`

