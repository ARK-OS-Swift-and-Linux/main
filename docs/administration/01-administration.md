# ArkOS System Administration

ArkOS is designed to be a locked-down, immutable operating system by default. Traditional Linux administration techniques (like editing files in `/etc` or running `apt-get upgrade`) do not apply here.

## Immutability and Root

By design, there is no persistent "root" user in a production ArkOS build.
-   `/system` is mounted read-only via `dm-verity`. You cannot `chmod` or `nano` files within it.
-   `/vendor` is mounted read-only.
-   The only writable partition is `/data` (often formatted as `f2fs`), which houses user configurations, downloaded apps, and cache.

To make system-level changes, a developer must modify the source code, rebuild the image using `aake`, and re-flash the device.

## OTA (Over-The-Air) Updates

System updates are handled atomically. ArkOS uses an A/B partition scheme.
1.  The device boots from Slot A (`sys_a.img`).
2.  When an update is downloaded (via configurations in `vendor/mirror/`), `arkrt` writes the new image bit-for-bit to Slot B (`sys_b.img`).
3.  The `vbmeta` is updated to point to Slot B.
4.  The system reboots into Slot B. If Slot B fails to boot (e.g., kernel panic), the bootloader automatically falls back to Slot A, ensuring the device is never bricked.

## Debugging and Logs

Since you cannot easily drop to a root shell, debugging relies on system logs.
-   **`dmesg`:** Standard kernel ring buffer.
-   **`arkrt` Logs:** The monolithic runtime writes its logs to `/data/logs/arkrt.log`. This file contains the lifecycle events of all services spawned by `.serve` files.
-   **Serial Console:** In development builds (configured via `bootconf.ark`), a root shell is spawned on `ttyS0`. This allows a developer to interact with the system via a UART cable.

## Resetting the System

Because all user state is isolated in `/data`, "factory resetting" an ArkOS device is instantaneous. The system simply unmounts `/data`, runs `mkfs.f2fs` to wipe the partition, and reboots. On the next boot, `arkrt` will launch the `setup_app` since no user profile exists.
