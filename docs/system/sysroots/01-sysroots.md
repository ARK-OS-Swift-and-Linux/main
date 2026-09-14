# ArkOS Sysroots

A "sysroot" (system root) is a directory containing the core standard libraries, headers, and essential binaries required to compile software for a specific target architecture. In ArkOS, sysroots are strictly managed to ensure cross-compilation is seamless.

## Structure

ArkOS maintains two primary sysroots:
1.  `system/sysroot/` (for x86_64)
2.  `system/sysrootaarch64/` (for ARM64)

Inside a sysroot, you typically find:
-   `usr/include/`: C standard library headers (glibc or musl), ArkOS framework headers, and Wayland protocols.
-   `usr/lib/`: Compiled shared objects (`.so`), static libraries (`.a`), and the Swift runtime libraries (`libswiftCore.so`).

## Cross-Compilation with Sysroots

When the `aake` build system cross-compiles an application (e.g., building an ARM64 app on an x86_64 laptop), it instructs the Clang compiler to use the ARM64 sysroot.

```bash
clang --target=aarch64-linux-gnu --sysroot=/home/arkos/repo/arkos/system/sysrootaarch64 -c main.c -o main.o
```

This ensures that:
1.  The compiler includes the ARM64 headers, not the host's x86_64 headers (preventing struct size mismatches).
2.  The linker (`ld`) links against the ARM64 libraries, avoiding "incompatible target" errors.

## Immutability

The sysroots in the source tree are considered immutable during a standard application build. They are only modified when updating the core OS dependencies (e.g., upgrading the Swift compiler or pulling a new version of `wayland-protocols`). When the final `sys.img` is built, the contents of the relevant sysroot are packed into the image.
