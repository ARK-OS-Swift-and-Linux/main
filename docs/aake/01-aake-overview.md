# Aake: The ArkOS Build System

`aake` is the central orchestration tool for compiling, testing, and packaging ArkOS. Built in C (`aake_src`), it aims to be faster and more domain-specific than a raw `Makefile`, while avoiding the bloat of massive build systems.

## Why a custom tool?

ArkOS requires a complex series of steps that a simple Makefile struggles to express cleanly:
1. Compiling C/Assembly bootloaders.
2. Compiling Swift runtime daemons and frameworks.
3. Generating boot animations from images (`font-gen`, `cursor-gen`).
4. Creating loopback devices, formatting ext4/FAT32 filesystems.
5. Cryptographically signing binaries for Verified Boot.

`aake` handles all of this natively.

## Architecture

`aake` acts as a meta-build system. It does not compile C files itself; instead, it generates build definitions and orchestrates other tools.

### Components
- **`main.c` / CLI parser:** Handles flags (`--x86_64`, `--uefi`, `-j`), performs memory validation, checks configuration (like `VISIBLE_BLUEPRINT`), and manages the environment context.
- **`blueprint.c`:** Scans the directory tree for `.aake.ark` files. It translates the declarative `.ark` configuration directly into raw `build.ninja` syntax stored in localized `.ninja/` subdirectories, and generates a master `build.ninja` file to link them.
- **`packager.c`:** Handles the generation of disk images (`initramfs`, `sys.img`, `rpi4.img`). It invokes `mkfs`, `cpio`, and `dd`.
- **`ninja_ui.c`:** A specialized wrapper around the `ninja` build tool that intercepts Ninja's output and presents a beautiful, ArkOS-themed progress bar in the terminal.

## Build Flow

1. **Pre-flight Checks:** `aake` determines the host architecture, prints the target information, and validates that the host has at least 6GB of RAM.
2. **Scan & Generate:** `aake` walks the source tree looking for `.aake.ark` files (or `aake.ark` if `VISIBLE_BLUEPRINT` is active). It emits individual `build.ninja` files into `.ninja/` subdirectories and a root `build.ninja` in `builddir/`.
3. **Ninja Build:** It invokes `ninja` to perform the actual parallel compilation.
4. **Package:** It gathers the compiled `.so` files, Swift binaries, and kernel images, moving them into `finished/`.
5. **Sign:** It invokes `vendor/verify/sign.py` to stamp the binaries for Verified Boot.
6. **Image Generation:** It constructs the final `ext4` and `FAT32` disk images.

## Features & Commands

- **`aake set VISIBLE_BLUEPRINT=true`**: This toggles the `aake.ark` configuration files from hidden (`.aake.ark`) to visible (`aake.ark`). By default, they are hidden to keep the project tree clean.
- **`aake clear --cache-only`**: Deletes the compiled objects in `builddir/` and the localized `.ninja/` configurations, without purging the final `finished/` binaries.

## Cross-Compilation

`aake` handles cross-compilation transparently. By passing `--arm64` on an x86_64 host, `aake` automatically sets the internal Ninja rules to point to the prebuilt Clang toolchain (`prebuilts/clang`) using `--target=aarch64-linux-gnu` and the appropriate sysroot.
