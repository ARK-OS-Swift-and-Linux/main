# ArkOS Kernel Configuration

ArkOS uses the Linux kernel as its hardware interaction layer. However, unlike traditional distributions (Ubuntu, Fedora) which ship generic, heavily-patched kernels with every conceivable module enabled, ArkOS takes a specialized approach.

## Kernel Source and Prebuilts

The `kernel/` directory in ArkOS contains two things:
1.  **Prebuilt Binaries:** For rapid development, prebuilt `bzImage` (x86_64) and `Image.gz` (AArch64) are stored here. This allows UI developers to build ArkOS in seconds without spending 30 minutes compiling the kernel.
2.  **Configuration Files (`.config`):** The exact configurations used to produce those prebuilts.

## Configuration Philosophy

The ArkOS kernel `.config` is heavily optimized for fast boot and security.

### 1. Minimal Modules
Whenever possible, drivers are built *into* the kernel (`=y`) rather than as modules (`=m`). This is especially true for critical path drivers:
-   NVMe and AHCI (SATA)
-   VirtIO (for QEMU testing)
-   ext4 and FAT32 filesystems
-   DRM (Direct Rendering Manager) core

This eliminates the need for `arkrt` to load modules during early boot, shaving crucial milliseconds off the boot time.

### 2. Security Hardening
-   **Page Table Isolation (PTI):** Enabled to mitigate Meltdown/Spectre.
-   **Strict `/dev/mem`:** Direct memory access from userspace is heavily restricted.
-   **Seccomp:** Enabled to allow `arkrt` to sandbox spawned services.

## Compiling the Kernel

If a hardware modification is needed, developers can recompile the kernel using `aake`:

```bash
aake build-kernel --x86_64
```
This command:
1. Downloads the mainline Linux kernel source (if not present).
2. Applies ArkOS specific patches (e.g., custom boot logos).
3. Compiles it using the prebuilt LLVM/Clang toolchain.
4. Replaces the prebuilt `bzImage` in the `kernel/` directory.
