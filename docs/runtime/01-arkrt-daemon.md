# ArkRT: The Monolithic Runtime Daemon

ArkRT is the beating heart of ArkOS. Running as PID 1, it replaces traditional init systems like `systemd` or `sysvinit`. Instead of spawning shell scripts or loosely coupled binaries, `arkrt` acts as a monolithic runtime environment where core system services, process management, network configuration, and the GUI daemon all live under a single unified Swift and C hybrid architecture.

## Overview

ArkRT is built heavily around Swift, utilizing Swift's memory safety, modern concurrency, and ABI stability to ensure the core OS layer is robust. For low-level kernel interactions, it drops down to C (using the `ark.sys.libc` and `ark.kernel.utils` packages).

Because it runs as PID 1, it handles:
1. Signal handling for the entire system (SIGCHLD, SIGTERM).
2. Service orchestration (starting network daemons, input handlers).
3. Session and User management.
4. Cryptographic Verified Boot validation.

## Boot Sequence Integration

When the Linux kernel finishes its initialization, it executes `/init`. In ArkOS, this is a symlink or direct binary to `arkrt`.
The initialization sequence goes as follows:

1. **Early Init (C-level):** `early_init.c` mounts API filesystems (`/proc`, `/sys`, `/dev`, `/run`). It populates `/dev` using a minimal `mdev` or `udev` equivalent built directly into ArkRT.
2. **Swift Runtime Spinup:** Once standard file descriptors are available, control is passed to `main.swift`.
3. **Verified Boot Check:** Before executing any third-party binaries or loading external libraries, ArkRT checks the cryptographic signatures of the system partitions against the `vbmeta` keys provided by the bootloader.
4. **Service Loading:** `ark.sys.service` parses `.serve` files in `/system/services/`. These describe dependencies, restart policies, and privileges.
5. **UI Daemon Start:** The `ark.display.graphics` subsystem initializes DRM/KMS, loads the Wayland compositor, and starts the ArkOS GUI.

## Core Packages

ArkRT is composed of several Swift packages mapping to critical system functions:

### `ark.sys.proc` (Process Management)
Replaces traditional `fork`/`exec` shell scripts with a structured Swift API. It monitors child processes, handles respawns for crashing services, and assigns cgroups for resource control.

### `ark.sys.service` (Service Manager)
The service manager uses a declarative syntax (similar to Android's `init.rc` but modernized in Swift/JSON-like `.serve` files).
It tracks service states: `stopped`, `starting`, `running`, `failed`. It guarantees that network-dependent services only start once `ark.service.network` reports a valid link.

### `ark.display.graphics`
ArkOS does not use X11. It uses a custom Wayland compositor embedded directly or managed tightly by ArkRT. It interfaces with `libdrm` for Direct Rendering Manager control, allocating framebuffers and setting up page flipping.

### `ark.service.network`
Replaces `NetworkManager`. Uses Netlink sockets to configure IP addresses, routes, and DNS.

## Security Contexts

Because ArkRT is monolithic, a compromise in one module could be catastrophic. To mitigate this:
1. Modules run in separate asynchronous tasks with strict capability bounds.
2. External services spawned by `ark.sys.proc` are heavily sandboxed using Linux namespaces (mount, pid, net, ipc) and seccomp filters.
3. IPC (Inter-Process Communication) between the GUI, the services, and ArkRT is handled via a specialized, strongly-typed memory-mapped RPC channel rather than generic D-Bus.
