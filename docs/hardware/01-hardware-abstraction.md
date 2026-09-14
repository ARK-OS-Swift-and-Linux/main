# ArkOS Hardware Abstraction Layer (HAL)

The hardware directory in ArkOS defines the hardware-specific configurations and board support packages (BSPs). Because ArkOS is built to run on diverse hardware (from desktop x86_64 PCs to embedded ARM64 SBCs), the Hardware Abstraction Layer ensures that the core `arkrt` and frameworks do not contain hardcoded hardware assumptions.

## Configuration Profiles (`.ark`)

Hardware configurations are defined in `.ark` files. These files dictate:
1.  **Device Tree Overlays (DTBOs):** Which overlays to apply for a specific board.
2.  **Kernel Modules:** Which modules must be loaded in the initramfs vs. which can be deferred to the main system partition.
3.  **Boot Parameters:** Hardware-specific kernel command line arguments (e.g., configuring the serial console baud rate).

## Structure

```
hardware/
├── generic-x86_64/
│   ├── config.ark
│   └── pci.ids
├── rpi4/
│   ├── config.ark
│   ├── bcm2711-rpi-4-b.dtb
│   └── overlays/
└── qemu-aarch64/
    └── config.ark
```

### Generic x86_64
The generic x86 profile is used for standard laptops and desktops. It configures the kernel to probe standard PCI and ACPI buses. The `config.ark` here instructs the `aake` build system to include DRM drivers for Intel, AMD, and basic VESA/EFI framebuffers.

### RPi4 (Raspberry Pi 4)
The Raspberry Pi 4 profile is highly specific. It relies on the Broadcom BCM2711 SoC. The `config.ark` here is vital as it configures the VideoCore VI GPU driver (`vc4`) and the custom boot firmware (`start4.elf`) required before the ARM CPU even powers on.

## HAL Interaction with `arkrt`

When `arkrt` boots, it reads `/proc/device-tree/model` or DMI tables to identify the hardware. It then loads the corresponding hardware profile from `/system/hardware/`. This profile dictates how `ark.display.graphics` configures the display output and how `ark.sys.service` brings up networking (e.g., loading the specific Wi-Fi firmware for the Cypress chip on the RPi4).
