# Practice 1

Goals:
  - [x] install ubuntu desktop
    - used arm64 image from: https://cdimage.ubuntu.com/releases/24.10/release/
    - used https://mac.getutm.app/ as gui for QEMU
  - [x] check internet connection
    - it worked out-of-the-box during the installation process
  - [x] update & upgrade apt packages
    - `sudo apt update && sudo apt upgrade`
    - (additionally) installed vim `sudo apt install vim`
  - [x] use shared folder
    - in UTM GUI set up shared folder using VirtFS:
      - on the host: `~/projects/virtual_machines_shared`
      - on the guest (according to https://docs.getutm.app/guest-support/linux/#virtfs):
        - add the following lines into the `/etc/fstab` using `sudo vim /etc/fstab`:
          ```
          # UTM Shared Folder
          share /mnt/utm 9p trans=virtio,version=9p2000.L,rw,_netdev,nofail,auto 0 0
          ```
        - create an empty folder: `sudo mkdir /mnt/utm`
        - `reboot`
        - check that mounted shared folder appears in `systemctl list-units --type mount`:
          - `mnt-utm.mount  loaded  active  mounted /mnt/utm`
        - fix file permissions (by default it's 600 and host is the only owner (except for the root))
          - using `ls -na /mnt/utm/` found out the host's UID=501 and GID=20
          - make a home folder for `bindfs`: `mkdir ~/utm`
          - find out guest's UID/GID: `id`
            - `uid=1000(yawkar) gid=1000(yawkar) groups=1000(yawkar),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users),114(lpadmin)`
            - UId=1000, GID=1000
          - add the following lines to remap host's UID/GID to guest's ones
            ```
            # bindfs mount to remap UID/GID (uid: 501 -> 1000, gid: 20 -> 1000)
            /mnt/utm /home/yawkar/utm fuse.bindfs map=501/1000:@20/@1000,x-systemd.requires=/mnt/utm,_netdev,nofail,auto 0 0
            ```
          - `reboot`
          - hmmm.... it didn't work, `systemctl list-units --type mount` shows that this bindfs mount has failed
          - looking for systemctl logs: `systemctl status home-yawkar-utm.mount`
            - it shows: "bindfs: not found"
            - install it: `sudo apt install bindfs`
            - try to restart systmectl service: `systemctl restart home-yawkar-utm.mount`
            - check `systemctl status home-yawkar-utm.mount`
            - Hurray! It's ok!
          - check permissions: `ls -na ~/utm`
          - HURRAY! it's 600 with UID=1000 GID=1000
  - [x] connect to the guest os through ssh from the host machine
    - in the UTM GUI added the following port-forwarding rule: protocol=TCP host=2222 guest=22
    - `sudo apt install openssh-server`
    - `systemctl reboot`
    - generate ssh key: `ssh-keygen -t rsa -b 4096` (saved as `/home/yawkar/.ssh/id_rsa`)
    - connect to vm: `ssh yawkar@localhost -p 2222`
    - success

