# ArkOS Boot Architecture

ArkOS employs a robust, highly modular boot process designed to ensure security, speed, and cross-platform compatibility from x86_64 UEFI/BIOS down to AArch64 systems like the Raspberry Pi 4. This document provides a deep, comprehensive breakdown of the initial system bring-up, memory initialization, and stage transitions that form the foundation of ArkOS.

## Table of Contents

1. [Boot Sequence Overview](#boot-sequence-overview)
2. [Stage 1: Primary Bootloader (Assembly)](#stage-1-primary-bootloader)
3. [Stage 2: C-Level Initialization (`bootloader.c`)](#stage-2-c-level-initialization)
4. [Initramfs & Mount Configuration](#initramfs--mount-configuration)
5. [Kernel Hand-off](#kernel-hand-off)

---

## Boot Sequence Overview

The boot sequence in ArkOS differs significantly from standard GRUB or systemd-boot setups. ArkOS uses a purpose-built, highly optimized bootloader residing in `boot/source`. The sequence is broadly split into two stages, followed by a verified hand-off to the `arkrt` monolithic runtime daemon.

1.  **Stage 1 (Hardware Initialization):** Written purely in architecture-specific assembly (`bootloader.asm`, `stage2.asm`). It handles basic CPU state setting (e.g., switching to protected/long mode on x86, or EL2/EL1 transitions on ARM), stack setup, and basic paging.
2.  **Stage 2 (Environment Setup):** A C-based environment (`bootloader.c`) parses `.ark` boot configuration files (like `bootconf.ark` and `vbmeta.ark`). It initializes framebuffers for the boot animation, sets up UEFI GOP or BIOS VBE, and locates the kernel and initramfs.
3.  **Initramfs Loading:** The `initramfs.img` is unpacked into memory. This archive contains critical early-stage drivers and the `arkrt` daemon.
4.  **Verification:** The `vbmeta.img` and Verified Boot keys (`vbk.img`) are verified against the loaded kernel and initramfs (detailed fully in `02-verified-boot.md`).
5.  **Execution Handoff:** The bootloader hands control over to the Linux kernel via the `bzImage` or `Image.gz` protocol, passing the memory-mapped initramfs and command line arguments.

---

## Stage 1: Primary Bootloader

The primary bootloader's sole responsibility is hardware abstraction.

### x86_64 Execution Path
For x86_64, the bootloader supports both legacy BIOS (using INT 10h for video, INT 13h for disk) and modern UEFI.
-   **UEFI:** Uses the standard UEFI application entry point (`efi_main`). It queries the `EFI_BOOT_SERVICES` to allocate memory and find the GOP (Graphics Output Protocol) for high-resolution graphics.
-   **BIOS:** `bootloader.asm` fits within the 512-byte MBR or a larger VBR. It enters 32-bit protected mode, loads `stage2.asm` from disk using BIOS interrupts, and transitions to 64-bit long mode by setting up the PML4 paging tables.

### AArch64 Execution Path
On AArch64 (e.g., Raspberry Pi 4), the firmware (e.g., `start4.elf` on RPi4) does the very heavy lifting. The ArkOS bootloader simply receives control in Exception Level 2 (EL2). It sets up the page tables (TTBR0_EL1, TTBR1_EL1), enables the MMU, and drops down to Exception Level 1 (EL1) before jumping to the C environment.

---

## Stage 2: C-Level Initialization

Once in C, `bootloader.c` takes over. This is where ArkOS starts reading its specialized configuration format (`.ark` files).

### Boot Configuration Parsing
The bootloader contains a minimal `.ark` parser.
-   **`bootconf.ark`**: Defines timeout, default kernel image, command-line arguments (like `console=ttyS0 quiet root=/dev/ram0`), and animation settings.
-   **`vbmeta.ark`**: Specifies the hashes and partitions to verify.

### Early Graphics and Boot Animation
ArkOS features a highly fluid, pre-generated boot animation. `bootloader.c` utilizes the framebuffer acquired in Stage 1 to draw frames located in `boot/source/animationframes/`. Because the kernel isn't loaded yet, this animation is driven entirely by the bootloader polling the hardware timer, providing immediate visual feedback before the kernel even decompresses.

---

## Initramfs & Mount Configuration

The initramfs (`initramfs.img`) in ArkOS is not just a temporary root; it acts as the staging ground for `arkrt`.
The bootloader maps this image into high memory. When the Linux kernel starts, it unpacks this gzip-compressed cpio archive.

The `initramfs.ark` configuration instructs the early kernel environment on how to mount the root filesystem. It defines:
-   `/dev/root` targets (e.g., UUID or partition label).
-   Filesystem types (`ext4`, `f2fs`).
-   Mount options (`ro`, `relatime`, `errors=remount-ro`).

---

## Kernel Hand-off

The final act of the bootloader is the kernel hand-off.
1.  **State Preparation:** The bootloader constructs the boot parameter struct (`boot_params` for x86_64, or the flattened device tree (FDT) for AArch64).
2.  **Memory Mapping:** The memory map provided by UEFI/BIOS/Firmware is translated into the format expected by the kernel (e.g., e820 map).
3.  **The Jump:** The bootloader flushes the CPU caches, disables interrupts, and executes an absolute jump to the kernel's entry point, passing the address of the boot parameters in a specific register (e.g., `%rsi` on x86, `x0` on ARM).

From this point forward, the Linux kernel controls the hardware, eventually executing `/init`, which in ArkOS is symmetrically linked to `arkrt`.
