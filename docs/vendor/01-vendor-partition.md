# ArkOS Vendor Partition

In modern operating systems, separating the core OS from hardware-specific proprietary blobs is essential for maintainability and security. ArkOS achieves this via the `vendor/` directory, which is packaged into a dedicated `vend.img` partition.

## The Purpose of `vend.img`

When `arkrt` boots, it mounts `sys.img` as `/system` (read-only) and `vend.img` as `/vendor` (read-only).
-   `/system` contains the open-source ArkOS frameworks, the Swift runtime, and the UI daemon.
-   `/vendor` contains closed-source drivers, firmware, DRM modules, and device-specific configuration.

This separation, inspired by Android's Project Treble, allows the core ArkOS (`sys.img`) to be updated independently of the hardware drivers (`vend.img`).

## Key Contents of `vendor/`

### 1. `Widevine/` (DRM)
ArkOS supports playing copy-protected media (Netflix, Hulu). Because the Widevine Content Decryption Module (CDM) is proprietary and requires secure hardware bindings (like TrustZone or Intel SGX), it cannot be compiled from source. The precompiled `.so` binaries reside in `/vendor/Widevine`. `ArkMedia` dynamically loads these binaries only when requested by an application.

### 2. `verify/` (Verified Boot Keys)
The `vendor/verify/` directory is the most critical security component. It contains the scripts (`sign.py`) and the root-of-trust keys (`securebuild.ark`) used to sign the `sys.img` and `vend.img`. During the build process, `aake` invokes these scripts to append RSA signatures to the images. (See `01-securebuild.md` for full details).

### 3. `mirror/` (OTA Updates)
Contains configuration for Over-The-Air (OTA) updates. This tells the system where to download new `sys.img` blocks.

## Hardware-Specific Firmware

While open-source drivers live in the kernel, many modern chips (Wi-Fi, Bluetooth, GPUs) require proprietary firmware blobs to function. For example, the Cypress Wi-Fi chip on the Raspberry Pi 4 requires a `.bin` firmware file. These blobs are placed in `/vendor/firmware/`. When the kernel requests firmware (via the userspace firmware helper or direct loading), `arkrt` intercepts the request and serves the file from the `vend.img`.
