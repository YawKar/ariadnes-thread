# Practice 3

Goals: Describe your OS

## General characteristics

- Architecture: aarch64 (`uname -pim`)
- Kernel release: 6.11.0-14-generic (`uname -r`)
- Kernel version: #15-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan 10 23:05:39 UTC 2025 (`uname -v`)
- Total memory (swap + mem): 11Gi (`free -ht`)
- Used memory (swap + mem): 1.1Gi (`free -ht`)
- Free memory (swap + mem): 9.4Gi (`free -ht`)

## Preinstalled packages

- Total amount: 1604 (`echo $(($(apt list --installed | wc -l) - 1))`)
- List of packages dumped: [02-practice-apt-list-installed.txt](./02-practice-apt-list-installed.txt)

## System boot process

1. We press "Power on" button and it lights up the motherboard.
2. Then BIOS or UEFI starts executing.
    - BIOS stands for "Basic Input Output System" specification of firmware
      - it's old (started at 1981)
      - it's not quite secure (it can boot drivers or loaders which weren't digitally signed)
      - it uses MBR (Master Boot Record) which is old and not flexible (limits the maximum hard drive size to 2.2TB)
    - UEFI stands for "Unified Extensible Firmware Interface" specification
      - it's new (started at 2006)
      - it's more secure ("Secure Boot" checks for digital signature of UEFI drivers and OS boot loaders)
      - it uses GPT (GUID Partition Table) which is new and flexible (limits maximum hard drive size to 9400000000 TB)
3. BIOS/UEFI runs POST which stands for "Power-On Self-Test"
    - it sets the initial state of the device and hardware components
    - it checks that there are no non-functional hardware components
    - results will be either displayed, stored for future retrieval or showed as a sequence of indicator flashes or sound beeps
    - what BIOS does during the POST:
      - verifies CPU registers
      - verifies integrity of the BIOS code
      - verifies basic components like timer or interrupt handler
      - verifies primary storage (the one to which CPU has direct access)
      - discovers, initializes and catalogs all system buses and devices
      - selects which devices are available for booting (in older systems POST didn't organize or select boot devices, it only identified floppy or hard disks)
4. According to BIOS/UEFI boot loading order it will run boot loader/boot manager such as GRUB(2) or LILO
    - MBR or GPT will point to GRUB/LILO
5. GRUB2/LILO loads linux kernel starter into memory and hands control over to it
6. The kernel (starter) takes over the computer resources and initiates background services
    - Firstly, it decompresses itself into memory, checks the hardware and loads device drivers and other kernel modules
    - Secondly, an "init" systemd process starts off (it is the parent of all other processes in linux)
      - systemd checks remaining hardware drivers
      - systemd mounts all file systems and disks so they're accessible
      - systemd launches networking, sound, power management
      - systemd handles users' logins
      - systemd loads desktop environment

