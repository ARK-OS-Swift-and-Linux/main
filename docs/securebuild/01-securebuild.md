# ArkOS SecureBuild (Verified Boot)

Security in ArkOS relies on a continuous chain of trust from the moment power is applied to the execution of the UI daemon. This concept, known as Verified Boot, ensures that an attacker cannot maliciously modify the kernel or system partitions to install a rootkit.

## The Root of Trust

The chain begins in hardware.
-   On an x86_64 PC, this is UEFI Secure Boot. The ArkOS bootloader is signed with a Microsoft-trusted key or a custom MOK (Machine Owner Key).
-   On a Raspberry Pi, this involves blowing OTP (One Time Programmable) fuses to force the VideoCore to only boot signed `start4.elf` firmware.

## The `vbmeta` Subsystem

Once the ArkOS bootloader executes, it must verify the next stage: the kernel and initramfs.

1.  **Build Time (`securebuild`):** During compilation, `aake` calls `vendor/verify/sign.py`. This script reads the private key from `vendor/verify/securebuild.ark`. It hashes the compiled kernel (`bzImage`), `initramfs.img`, `sys.img`, and `vend.img` using SHA-256. It then signs these hashes using RSA. The resulting signatures and public key are packed into `vbmeta.img`.
2.  **Boot Time (Bootloader):** The C-level bootloader (`bootloader.c`) reads `vbmeta.img`. It extracts the public key and the expected hashes. It then hashes the kernel and initramfs currently sitting in memory. If the computed hash does not match the decrypted signature in `vbmeta.img`, the bootloader halts the system with a red screen, preventing the compromised kernel from executing.

## `arkrt` and DM-Verity

The bootloader only verifies the kernel and initramfs because verifying a 2GB `sys.img` in memory would take too long.
Instead, ArkOS relies on the Linux kernel's `dm-verity` (Device Mapper Verity) feature.

1.  When `arkrt` starts from the initramfs, it reads the expected root hash of the `sys.img` Merkle tree from the verified `vbmeta.img`.
2.  It mounts `sys.img` and `vend.img` using the `dm-verity` target.
3.  As files are read from the system partition during normal operation, the kernel transparently hashes the data blocks on-the-fly and compares them against the Merkle tree.
4.  If a single byte on the disk was altered offline by an attacker, the kernel throws an I/O error, and `arkrt` instantly reboots the system to prevent compromised code execution.
