# ArkOS QEMU Emulation

QEMU is the primary development and testing target for ArkOS. It allows rapid iteration of kernel changes, bootloader modifications, and UI development without requiring constant flashing to physical hardware.

## Supported Architectures

ArkOS uses QEMU to test both primary architectures:
1.  **x86_64:** Tested using `qemu-system-x86_64`.
2.  **AArch64:** Tested using `qemu-system-aarch64`.

## Testing via `aake`

The `aake` command-line tool wraps QEMU invocations, automatically constructing the complex QEMU command line required to boot ArkOS correctly.

### x86_64 Emulation

**BIOS Mode:**
```bash
aake test --x86_64 --bios
```
This tests the legacy boot path (`bootloader.asm` MBR/VBR). QEMU is launched with standard PC machine type (`-M pc`), passing the generated `boot.img` as a raw drive.

**UEFI Mode:**
```bash
aake test --x86_64 --uefi
```
This tests the modern EFI boot path. `aake` automatically locates the OVMF (Open Virtual Machine Firmware) binaries (`OVMF_CODE.fd`, `OVMF_VARS.fd`) and mounts the boot image as an EFI system partition.

### AArch64 Emulation

```bash
aake test --arm64 --uefi
```
For ARM64, `aake` uses the `virt` machine type (`-M virt`). It utilizes the QEMU EFI firmware (AAVMF) to simulate a standard ARM Server Base System Architecture (SBSA) environment, booting the AArch64 kernel and initramfs.

## Hardware Acceleration

To ensure the UI and animations are smooth during testing, `aake` automatically detects the host architecture.
-   If compiling x86_64 on an x86_64 host, it passes `-enable-kvm -cpu host`.
-   If compiling AArch64 on an x86_64 host (Cross-compilation), it falls back to TCG software emulation. This is slower but guarantees functional correctness.

## VirtIO Integration

ArkOS leverages QEMU's VirtIO devices for maximum performance:
-   **virtio-gpu:** Provides 2D/3D graphics acceleration. `arkrt` DRM subsystem targets `virtio_gpu` to render the UI.
-   **virtio-blk:** Used for fast block storage access to `sys.img` and `vend.img`.
-   **virtio-net:** Configured via user-mode networking (`-netdev user`) to give the emulated ArkOS internet access for package fetching or update testing.
