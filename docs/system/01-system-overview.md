# ArkOS System Architecture

The `system/` directory in ArkOS is analogous to `/usr` and `/etc` in a traditional Linux distribution, but heavily streamlined. It contains the core OS components that run in userspace, built upon the foundation of `arkrt`.

## Core Components

### 1. `apps/`
Contains system-level applications essential for the OS to function.
-   **`setup_app`**: The Out-Of-Box Experience (OOBE). This is the first graphical application run by `arkrt` if no user account exists. It handles Wi-Fi configuration, user creation, and time zone settings.
-   **`sys_monitor`**: A lightweight background service providing telemetry to the UI (battery, CPU temp).

### 2. `display/`
The UI daemon and compositor. While `ark.display.graphics` handles the low-level DRM/KMS, the `display/` directory contains the actual Window Manager logic, drawing the top status bar, handling touch/mouse inputs via `libinput`, and dispatching Wayland events to applications.

### 3. `services/`
Contains the `.serve` declarative configuration files defining how background processes run (documented fully in `system/services/01-services.md`).

### 4. `sysroot/` and `sysrootaarch64/`
These directories contain the base libraries and directory structures required to compile and run applications for their respective architectures.

## Execution Flow

When `arkrt` boots the system:
1. It mounts the `sys.img` (which contains the compiled contents of the `system/` directory) to `/system`.
2. It parses `/system/services/` to bring up the network and hardware daemons.
3. It launches the compositor located in `/system/display/`.
4. The compositor loads the user session or the `setup_app` from `/system/apps/`.
