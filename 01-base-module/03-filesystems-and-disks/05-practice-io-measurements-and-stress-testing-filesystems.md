# Практика 5

Цель: выполнить требования и задачи.

# Требования и задачи

0. Будем использовать `sudo apt install fio`
1. (смержил с 2-ым пунктом)
2. Измерение скорости записи/скорость чтения файловых систем.
  - Для каждой файловой системы выполните тест записи.
    - `lsblk | grep /mnt/disk3`, найдем какому разделу соответствует какое устройство
      ```
      loop3    7:3    0   158M  0 loop /mnt/disk3p2
      loop4    7:4    0   158M  0 loop /mnt/disk3p3
      loop5    7:5    0   158M  0 loop /mnt/disk3p1
      loop6    7:6    0   350M  0 loop /mnt/disk3p4
      ```
    - `parted disk3.img print`, освежим в памяти, кто где
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
    - протестим файловые системы
      - `ext4`
        - `fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --bs=4k --iodepth=64 --readwrite=randrw --rwmixread=75 --size=100M --filename=/mnt/disk3p1/testblob`, создадим 100M файл и прогоним тестик из манулов
          ```
          test: (g=0): rw=randrw, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
          fio-3.37
          Starting 1 process
          test: Laying out IO file (1 file / 100MiB)

          test: (groupid=0, jobs=1): err= 0: pid=144653: Sun Feb 23 22:17:19 2025
            read: IOPS=243k, BW=951MiB/s (997MB/s)(75.1MiB/79msec)
            write: IOPS=80.6k, BW=315MiB/s (330MB/s)(24.9MiB/79msec); 0 zone resets
            cpu          : usr=8.97%, sys=58.97%, ctx=304, majf=0, minf=16
            IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.8%
               submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
               complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
               issued rwts: total=19233,6367,0,0 short=0,0,0,0 dropped=0,0,0,0
               latency   : target=0, window=0, percentile=100.00%, depth=64

          Run status group 0 (all jobs):
             READ: bw=951MiB/s (997MB/s), 951MiB/s-951MiB/s (997MB/s-997MB/s), io=75.1MiB (78.8MB), run=79-79msec
            WRITE: bw=315MiB/s (330MB/s), 315MiB/s-315MiB/s (330MB/s-330MB/s), io=24.9MiB (26.1MB), run=79-79msec

          Disk stats (read/write):
            loop5: ios=5765/1981, sectors=46120/15848, merge=0/0, ticks=700/237, in_queue=936, util=18.05%
          ```
      - `btrfs`
        - `fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --bs=4k --iodepth=64 --readwrite=randrw --rwmixread=75 --size=50M --filename=/mnt/disk3p2/testblob`, создадим 50M файл и прогоним тестик из манулов
          ```
          test: (g=0): rw=randrw, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
          fio-3.37
          Starting 1 process
          test: Laying out IO file (1 file / 50MiB)

          test: (groupid=0, jobs=1): err= 0: pid=439514: Sun Feb 23 23:35:58 2025
            read: IOPS=92.2k, BW=360MiB/s (378MB/s)(37.5MiB/104msec)
            write: IOPS=30.9k, BW=121MiB/s (126MB/s)(12.5MiB/104msec); 0 zone resets
            cpu          : usr=0.97%, sys=52.43%, ctx=2131, majf=0, minf=13
            IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.2%, >=64=99.5%
               submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
               complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
               issued rwts: total=9590,3210,0,0 short=0,0,0,0 dropped=0,0,0,0
               latency   : target=0, window=0, percentile=100.00%, depth=64

          Run status group 0 (all jobs):
             READ: bw=360MiB/s (378MB/s), 360MiB/s-360MiB/s (378MB/s-378MB/s), io=37.5MiB (39.3MB), run=104-104msec
            WRITE: bw=121MiB/s (126MB/s), 121MiB/s-121MiB/s (126MB/s-126MB/s), io=12.5MiB (13.1MB), run=104-104msec
          ```
      - `xfs`
        - `fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --bs=4k --iodepth=64 --readwrite=randrw --rwmixread=75 --size=150M --filename=/mnt/disk3p4/testblob`, создадим 150M файл и прогоним тестик из манулов
          ```
          test: (g=0): rw=randrw, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
          fio-3.37
          Starting 1 process
          test: Laying out IO file (1 file / 150MiB)

          test: (groupid=0, jobs=1): err= 0: pid=453794: Sun Feb 23 23:39:18 2025
            read: IOPS=236k, BW=922MiB/s (967MB/s)(112MiB/122msec)
            write: IOPS=78.8k, BW=308MiB/s (323MB/s)(37.5MiB/122msec); 0 zone resets
            cpu          : usr=4.13%, sys=63.64%, ctx=460, majf=0, minf=16
            IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.8%
               submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
               complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
               issued rwts: total=28789,9611,0,0 short=0,0,0,0 dropped=0,0,0,0
               latency   : target=0, window=0, percentile=100.00%, depth=64

          Run status group 0 (all jobs):
             READ: bw=922MiB/s (967MB/s), 922MiB/s-922MiB/s (967MB/s-967MB/s), io=112MiB (118MB), run=122-122msec
            WRITE: bw=308MiB/s (323MB/s), 308MiB/s-308MiB/s (323MB/s-323MB/s), io=37.5MiB (39.4MB), run=122-122msec

          Disk stats (read/write):
            loop6: ios=0/0, sectors=0/0, merge=0/0, ticks=0/0, in_queue=0, util=0.00%
          ```
  - Составим таблицу итоговую.
    ```
    Filesystem    Write Speed   Read Speed
    ext4          330MB/s       997MB/s
    xfs           323MB/s       967MB/s
    btrfs         126MB/s       378MB/s
    ```
3. Тестирование устойчивости к аварийной перезагрузке.
  - Создайте файлы на каждом диске
    - первый диск состоит из одного раздела, который маунтится в `ro`, поэтому я на него забью
    - `echo "hello" > /tmp/lolkek`
    - (`sudo`, потому на многих разделах я не делал `chmod 777 -R`)
    - `sudo cp /tmp/lolkek /mnt/disk2p1/lolkek`
    - `sudo cp /tmp/lolkek /mnt/disk2p2/lolkek`
    - `echo {1..4} | tr [:space:] \\n | xargs -I % sudo cp /tmp/lolkek /mnt/disk3p%` (а то заколебывает менять индекс стрелочками)
  - Сделайте аварийную перезагрузку.
    - проверим, что триггер существует: `test -e /proc/sysrq-trigger && echo "exists"`
    - проверим, что он включен: `test 0 -ne $(cat /proc/sys/kernel/sysrq) && echo "it's enabled"`
    - пульнем в него сигналом на аварийную перезагрузку: `sudo su`, `echo b > /proc/sysrq-trigger`
  - Проверьте целостность данных с помощью утилит
    - сначала за анмаунтим все разделы с третьего диска прежде чем проверять файловые системы
      - `sudo umount /mnt/disk3*`
    - теперь создадим для них блочные устройства
      - `sudo losetup --partscan --find --show disk3.img`
        - `/dev/loop3`
    - теперь для 1-го раздела с ext4 проверим через `e2fsck`
      - `sudo e2fsck /dev/loop3p1 -fv` (`-f` to force it, `-v` to be verbose)
        ```
        e2fsck 1.47.1 (20-May-2024)
        Pass 1: Checking inodes, blocks, and sizes
        Pass 2: Checking directory structure
        Pass 3: Checking directory connectivity
        Pass 4: Checking reference counts
        Pass 5: Checking group summary information

                  13 inodes used (0.03%, out of 40448)
                   0 non-contiguous files (0.0%)
                   0 non-contiguous directories (0.0%)
                     # of inodes with ind/dind/tind blocks: 0/0/0
                     Extent depth histogram: 5
                6709 blocks used (16.59%, out of 40448)
                   0 bad blocks
                   1 large file

                   1 regular file
                   2 directories
                   0 character device files
                   0 block device files
                   0 fifos
                   0 links
                   0 symbolic links (0 fast symbolic links)
                   0 sockets
        ------------
                   3 files
        ```
    - теперь для 2-го раздела с btrfs проверим через `btrfs check`
      - `sudo btrfs check /dev/loop3p2`
        ```
        [1/7] checking root items
        [2/7] checking extents
        [3/7] checking free space tree
        [4/7] checking fs roots
        [5/7] checking only csums items (without verifying data)
        [6/7] checking root refs
        [7/7] checking quota groups skipped (not enabled on this FS)
        Opening filesystem to check...
        Checking filesystem on /dev/loop3p2
        UUID: e26e06d8-b74e-4dc7-9dfd-0017f17a98b6
        found 66609152 bytes used, no error found
        total csum bytes: 64040
        total tree bytes: 1032192
        total fs tree bytes: 540672
        total extent tree bytes: 294912
        btree space waste bytes: 254376
        file data blocks allocated: 38189703168
         referenced 52428800
        ```
    - теперь для 4-го раздела с xfs проверим через `xfs_repair`
      - `sudo xfs_repair -v /dev/loop3p4`
        ```
        Phase 1 - find and verify superblock...
                - block cache size set to 352408 entries
        Phase 2 - using internal log
                - zero log...
        zero_log: head block 76 tail block 76
                - scan filesystem freespace and inode maps...
                - found root inode chunk
        Phase 3 - for each AG...
                - scan and clear agi unlinked lists...
                - process known inodes and perform inode discovery...
                - agno = 0
                - agno = 1
                - agno = 2
                - agno = 3
                - process newly discovered inodes...
        Phase 4 - check for duplicate blocks...
                - setting up duplicate extent list...
                - check for inodes claiming duplicate blocks...
                - agno = 0
                - agno = 1
                - agno = 2
                - agno = 3
        Phase 5 - rebuild AG headers and trees...
                - agno = 0
                - agno = 1
                - agno = 2
                - agno = 3
                - reset superblock...
        Phase 6 - check inode connectivity...
                - resetting contents of realtime bitmap and summary inodes
                - traversing filesystem ...
                - agno = 0
                - agno = 1
                - agno = 2
                - agno = 3
                - traversal finished ...
                - moving disconnected inodes to lost+found ...
        Phase 7 - verify and correct link counts...

                XFS_REPAIR Summary    Tue Feb 25 01:08:03 2025

        Phase		Start		End		Duration
        Phase 1:	02/25 01:08:02	02/25 01:08:02
        Phase 2:	02/25 01:08:02	02/25 01:08:02
        Phase 3:	02/25 01:08:02	02/25 01:08:03	1 second
        Phase 4:	02/25 01:08:03	02/25 01:08:03
        Phase 5:	02/25 01:08:03	02/25 01:08:03
        Phase 6:	02/25 01:08:03	02/25 01:08:03
        Phase 7:	02/25 01:08:03	02/25 01:08:03

        Total run time: 1 second
        done
        ```
4. Отчет о нагрузке.
  - Используем `iostat` для анализа нагрузки на диски.
    - просто запускаем `iostat 1` и смотрим
      ```
      avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                 4.58    0.00    5.09    0.00    0.00   90.33

      Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
      loop0             0.00         0.00         0.00         0.00          0          0          0
      loop1             0.00         0.00         0.00         0.00          0          0          0
      loop10            0.00         0.00         0.00         0.00          0          0          0
      loop11            0.00         0.00         0.00         0.00          0          0          0
      loop12            0.00         0.00         0.00         0.00          0          0          0
      loop13            0.00         0.00         0.00         0.00          0          0          0
      loop14            0.00         0.00         0.00         0.00          0          0          0
      loop15            0.00         0.00         0.00         0.00          0          0          0
      loop16            0.00         0.00         0.00         0.00          0          0          0
      loop17            0.00         0.00         0.00         0.00          0          0          0
      loop18            0.00         0.00         0.00         0.00          0          0          0
      loop19            0.00         0.00         0.00         0.00          0          0          0
      loop2             0.00         0.00         0.00         0.00          0          0          0
      loop20            0.00         0.00         0.00         0.00          0          0          0
      loop21            0.00         0.00         0.00         0.00          0          0          0
      loop22            0.00         0.00         0.00         0.00          0          0          0
      loop23            0.00         0.00         0.00         0.00          0          0          0
      loop24            0.00         0.00         0.00         0.00          0          0          0
      loop25            0.00         0.00         0.00         0.00          0          0          0
      loop26            0.00         0.00         0.00         0.00          0          0          0
      loop3             0.00         0.00         0.00         0.00          0          0          0
      loop4             0.00         0.00         0.00         0.00          0          0          0
      loop5             0.00         0.00         0.00         0.00          0          0          0
      loop6             0.00         0.00         0.00         0.00          0          0          0
      loop7             0.00         0.00         0.00         0.00          0          0          0
      loop8             0.00         0.00         0.00         0.00          0          0          0
      loop9             0.00         0.00         0.00         0.00          0          0          0
      vda               4.95         0.00        35.64         0.00          0         36          0
      ```

