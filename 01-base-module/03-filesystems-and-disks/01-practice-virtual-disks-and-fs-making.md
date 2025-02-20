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
  - Используйте `parted` для гибкой разметки третьего диска
    - `parted disk3.img`
    - `help mktable`, видим какие есть типы, выбираем gpt
    - `mktable gpt`
    - `help mkpart`, видим какие типы разделов есть (primary, logical, extended), типы файловых систем (mkpart не создает файловые системы, а лишь укажет у раздела соответствующий partition ID)
    - сделаем 4 primary раздела с partition ID: ext4, xfs, btrfs, ext4
      - `unit B`, чтобы посмотреть, где заканчивается таблица разделов и откуда можно начать создавать первый раздел
      - `print free`, видим что свободное место начинается с `17408B`
        - посчитаем в секторах: `17408B / 512B/s = 34s`
        - пусть хотим 150MiB~ на каждом разделе: `150 * 1024 * 1024 / 512 = 323584s`
        - но `parted` говорит, что это не бьется на `2048s` (for the best performance), поэтому давайте за-align'им немножко
        - начнем с `2048s`, а закончим на `2048s + 323584s - 1s = 325631s` (`-1s`, чтобы начать со следующего батча, кратного `2048s`, для следующего раздела)
      - `mkpart primary ext4 2048s 325631s`
      - `mkpart primary xfs 325632s 649215s`
        - `325631s + 1s = 325632s` (рядышком прям благодаря тому, что предыдущий раздел заканчивается впритык к новому `2048s` батчу)
        - `325632s + 323584s - 1s = 649215s`, `-1s` опять-таки, чтобы все билось на `2048s`
      - `mkpart primary btrfs 649216s 972799s`
        - `649215s + 1s = 649216s`
        - `649216s + 323584s - 1s = 972799s`
      - `mkpart primary ext4 972800s 1296383s`
        - `972799s + 1s = 972800s`
        - `972800s + 323584s - 1s = 1296383s`
      - проверяем `print`:
        ```
        (parted) print
        Model:  (file)
        Disk /home/yawkar/trash/disk3.img: 1073741824B
        Sector size (logical/physical): 512B/512B
        Partition Table: gpt
        Disk Flags:

        Number  Start       End         Size        File system  Name     Flags
         1      1048576B    166723583B  165675008B  ext4         primary
         2      166723584B  332398591B  165675008B  xfs          primary
         3      332398592B  498073599B  165675008B  btrfs        primary
         4      498073600B  663748607B  165675008B  ext4         primary
        ```
      - я ещё открыл этот диск потом с `fdisk -l disk3.img` и у меня слетели все Type-UUID файловых систем :)
        ну ладно, накатим потом, все равно они пока были тупо ярлыками
      - накатываем файловые системы на них
        - для этого надо сначала примаунтить все разделы
          - `losetup --find --partscan --show disk3.img`
            - `/dev/loop18`
        - теперь можно катить фски
          - `sudo mkfs.ext4 /dev/loop18p1`
          - `sudo mkfs.xfs /dev/loop18p2`
            - оу shit, xfs должна быть больше 300MB по размеру, а у нас 150MB
          - `sudo mkfs.btrfs /dev/loop18p3`
          - `sudo mkfs.ext4 /dev/loop18p4`
        - все кроме xfs удачно созданы, поэтому давайте удалим раздел с xfs, сдвинем разделы влево и добавим под xfs большой раздел на 350MiB
          - `sudo losetup -d /dev/loop18`, чтобы отключить диск
          - `parted disk3.img` и `print`, видим номер xfs раздела 2-ой
            - `rm 2`, чтобы удалить раздел
          - `fdisk disk3.img`
            - `x`, чтобы перейти в экспертный режим
            - `f`, чтобы пофиксить порядок разделов (а то у нас теперь 1, 3 и 4)
            - `r`, вернуться в меню
            - `w`, сохранить изменения
          - `parted disk3.img` и `print`, теперь видим, что у нас 1 2 3 разделы
          - `echo '-323584' | sfdisk disk3.img --move-data -N 2`, сдвигаем 2-ой раздел влево на 323584 сектора
          - `echo '-323584' | sfdisk disk3.img --move-data -N 3`, сдвигаем 3-ий раздел влево на 323584 сектора
          - `parted disk3.img print`, проверяем, что все 3 раздела теперь идут подряд
            ```
            Model:  (file)
            Disk /home/yawkar/trash/disk3.img: 1074MB
            Sector size (logical/physical): 512B/512B
            Partition Table: gpt
            Disk Flags: 

            Number  Start   End    Size   File system  Name     Flags
             1      1049kB  167MB  166MB  ext4         primary
             2      167MB   332MB  166MB  btrfs        primary
             3      332MB   498MB  166MB  ext4         primary
            ```
          - теперь пересоздадим новый раздел под xfs с размером 350MiB
            - `parted disk3.img`, `unit s` (чтобы посмотреть в секторах, где начало)
            - `parted disk3.img mkpart primary xfs 972800s 1689599s`
              - считаем сколько 350MiB в секторах: `350 * 1024 * 1024 / 512 = 716800s`
              - считаем последний сектор: `972800s + 716800s - 1s = 1689599s`
            - `sudo losetup --find --partscan --show disk3.img`
              - `/dev/loop18`
            - `sudo mkfs.xfs /dev/loop18p4 -f`, `-f`, потому что `parted` какого-то прикола установил лейбл ext4 файловой системы, хотя я просил xfs
          - проверяем: `parted disk3.img print`
            ```
            Model:  (file)
            Disk /home/yawkar/trash/disk3.img: 1074MB
            Sector size (logical/physical): 512B/512B
            Partition Table: gpt
            Disk Flags:

            Number  Start   End    Size   File system  Name     Flags
             1      1049kB  167MB  166MB  ext4         primary
             2      167MB   332MB  166MB  btrfs        primary
             3      332MB   498MB  166MB  ext4         primary
             4      498MB   865MB  367MB  xfs          primary
            ```
3. Настройка файловой системы
  - Потюним ext4 (посмотрел btrfs, но ничего особо прикольного потюнить не нашел)
    - установим количество зарезервированных для суперпользака блоков в 1% от общего числа
      - `sudo tune2fs -m 1 /dev/loop18p1`
    - установим макс количество маунтов до проверки целостности в 10
      - `sudo tune2fs -c 10 /dev/loop18p1`
    - установим интервал между проверками целостности в 1 неделю
      - `sudo tune2fs -i 1w /dev/loop18p1`
    - прикажем фс перемаунтиться в случае возникновения ошибки в read-only режиме
      - `sudo tune2fs -e remount-ro /dev/loop18p1`
    - поменяем лейбл
      - `sudo tune2fs -L "top partition" /dev/loop18p1`
  - проверим целостность файловых систем
    - `sudo fsck.ext4 /dev/loop18p1`
    - `sudo btrfs check /dev/loop18p2`
    - `sudo fsck.ext4 /dev/loop18p3`
    - `sudo xfs_repair /dev/loop18p4`

