# Raspberry Pi 4 (AArch64) Support in ArkOS

ArkOS treats the Raspberry Pi 4 as a first-class citizen for AArch64 development and deployment. This document outlines the specifics of the RPi4 integration, boot process, and hardware utilization.

## Boot Sequence

The RPi4 boot process is unique because the GPU (VideoCore VI) boots first, not the CPU.
1.  **GPU Boot:** The VideoCore VI loads `bootcode.bin` (on EEPROM) and `start4.elf` from the SD card's FAT32 boot partition.
2.  **Configuration:** `config.txt` instructs the GPU to load the device tree (`bcm2711-rpi-4-b.dtb`) and the ArkOS primary bootloader binary (usually named `kernel8.img` for 64-bit).
3.  **CPU Execution:** The ARM Cortex-A72 cores are released from reset. ArkOS `bootloader.asm` executes in EL2, drops to EL1, and parses the FDT (Flattened Device Tree).
4.  **Display Initialization:** The bootloader utilizes the simple framebuffer setup by the firmware to display the ArkOS boot animation while loading the Linux kernel.

## Graphics and Multimedia

ArkOS leverages the `vc4` DRM (Direct Rendering Manager) driver.
-   **Display:** Dual micro-HDMI output is supported up to 4K. ArkRT's `ark.display.graphics` maps to the DRM nodes (`/dev/dri/card0`) to achieve tear-free Wayland compositing.
-   **Video Decoding:** Hardware-accelerated HEVC (H.265) and AVC (H.264) decoding is exposed through the V4L2 Memory-to-Memory (m2m) API, integrated into `ArkMedia`.

## Storage and I/O

-   **SD Card:** The primary boot medium. ArkOS uses the `ext4` filesystem for the `/system` and `/vendor` partitions, while the boot partition remains FAT32.
-   **USB 3.0 / PCIe:** The USB 3.0 ports are routed through a PCIe-to-USB controller (VL805). ArkOS kernel configurations ensure PCIe and XHCI drivers are built-in or present in the initramfs.

## Flashing

The `aake` build system automates the creation of the final `rpi4.img`. This image contains:
1.  Partition 1: FAT32 (`boot.img` contents, firmware, DTBs).
2.  Partition 2: ext4 (`sys.img` - ArkRT and frameworks).
3.  Partition 3: ext4 (`vend.img` - Verified boot keys, mirror info).

```bash
sudo dd if=finished/rpi4/rpi4.img of=/dev/sdX bs=4M status=progress
sync
```
