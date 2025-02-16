# Практика 1

Цели:
  - [x] установить ubuntu desktop
    - использую arm64 image по ссылке: https://cdimage.ubuntu.com/releases/24.10/release/
    - а также https://mac.getutm.app/ в качестве GUI прослойки до QEMU
  - [x] проверить интернет соединение
    - работало из коробки во время установки и после
  - [x] обновить каталог пакетов и сами пакеты
    - `sudo apt update && sudo apt upgrade`
    - (дополнительно) установил vim `sudo apt install vim`
  - [x] использовать общую между хостом и гостем директорию
    - в UTM GUI настроил общую директорию через VirtFS:
      - host: `~/projects/virtual_machines_shared`
      - guest (следуя инструкции https://docs.getutm.app/guest-support/linux/#virtfs):
        - добавил новую точку монтирования в `/etc/fstab` через `sudo vim /etc/fstab`:
          ```
          # UTM Shared Folder
          share /mnt/utm 9p trans=virtio,version=9p2000.L,rw,_netdev,nofail,auto 0 0
          ```
        - создал пустую директорию: `sudo mkdir /mnt/utm`
        - `reboot`
        - проверил, что примаунченная директория появляется в выводе `systemctl list-units --type mount`:
          - `mnt-utm.mount  loaded  active  mounted /mnt/utm`
        - нужно пофиксить права доступа (по дефолту они 600 и хост единственный овнер (помимо root))
          - с помощью `ls -na /mnt/utm/` нашел host'овые UID=501 and GID=20
          - создаю директорию в домашней директории под ремапнутую fs с типом `bindfs`: `mkdir ~/utm`
          - нашел свои гостевые UID/GID через команду: `id`
            - `uid=1000(yawkar) gid=1000(yawkar) groups=1000(yawkar),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users),114(lpadmin)`
            - UID=1000, GID=1000
          - добавляю в `/etc/fstab` следующую конфигурацию новой точки монтирования, которая ремапит UID&GID хоста в мои гостевые
            ```
            # bindfs mount to remap UID/GID (uid: 501 -> 1000, gid: 20 -> 1000)
            /mnt/utm /home/yawkar/utm fuse.bindfs map=501/1000:@20/@1000,x-systemd.requires=/mnt/utm,_netdev,nofail,auto 0 0
            ```
          - `reboot`
          - хм, оно не сработало, `systemctl list-units --type mount` показывает, что моя точка зафейлилась
          - смотрю статус таски, мб там в логах увижу проблему: `systemctl status home-yawkar-utm.mount`
            - показывает: "bindfs: not found"
            - устанавливаю: `sudo apt install bindfs`
            - рестарчу сервис: `systemctl restart home-yawkar-utm.mount`
            - проверяю `systemctl status home-yawkar-utm.mount`
            - супер, заработало
          - проверяю права доступа вновь: `ls -na ~/utm`
          - супер! показывает 600 с UID=1000 GID=1000
  - [x] подключиться к гостевой ОС через ssh с хоста
    - в UTM GUI добавил следующее правило для проброса порта: protocol=TCP host=2222 guest=22
    - `sudo apt install openssh-server` на госте
    - `systemctl reboot`
    - generate ssh key: `ssh-keygen -t rsa -b 4096` (сохранил `/home/yawkar/.ssh/id_rsa`)
    - подключаюсь по порту: `ssh yawkar@localhost -p 2222`, ввожу пароль
    - успешно зашел

