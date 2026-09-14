# AArch64 (ARM64) Architecture in ArkOS

The AArch64 architecture represents the modern, low-power, high-performance future of computing. ArkOS deeply integrates AArch64 specific optimizations, targeting embedded boards like the Raspberry Pi 4 and future ARM-based laptops.

## Execution State and Privilege Levels

ArkOS utilizes the AArch64 Exception Levels (EL) to enforce security:
-   **EL3 (Secure Monitor):** Typically handled by ARM Trusted Firmware (ATF). ArkOS does not implement EL3 directly but relies on vendor firmware to transition to EL2.
-   **EL2 (Hypervisor):** The ArkOS `bootloader.asm` receives control here. It configures the virtualization extensions if needed, but its primary job is to set up the MMU and drop to EL1.
-   **EL1 (Kernel):** The Linux kernel and `arkrt` core (in some privileged contexts) operate here.
-   **EL0 (Userspace):** All ArkOS frameworks, UI daemons, and applications run in EL0.

## Memory Management Unit (MMU)

The AArch64 MMU is configured to use a 4KB page size with 48-bit virtual addressing (yielding a 256TB address space).
-   **TTBR0_EL1:** Points to the page tables for userspace (EL0).
-   **TTBR1_EL1:** Points to the page tables for the kernel space (EL1).

## Device Trees (FDT)

Unlike x86_64 which uses ACPI to discover hardware, AArch64 relies on the Flattened Device Tree (FDT).
When building for AArch64, `aake` compiles `.dts` (Device Tree Source) files into `.dtb` (Device Tree Blob) binaries. The bootloader loads this `.dtb` into memory and passes its memory address to the Linux kernel via the `x0` register. The kernel parses this tree to know exactly what hardware exists (e.g., memory ranges, UART addresses, GPIO pins).
