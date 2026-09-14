# ArkOS Compilers and Toolchains

Building an entire operating system requires strict control over the toolchain to ensure reproducible builds, memory safety, and ABI compatibility across the monolithic daemon (`arkrt`) and system frameworks.

ArkOS does not rely on the host system's `gcc` or `clang`. Instead, it uses tightly controlled, prebuilt toolchains located in the `prebuilts/` directory.

## 1. LLVM / Clang

ArkOS is entirely compiled using Clang. GCC is not used for any OS-level components.

**Why Clang?**
-   **Swift Interoperability:** Swift uses LLVM as its backend. Compiling the C components with Clang ensures seamless linking and LTO (Link Time Optimization) across language boundaries.
-   **Fast Compilation:** Clang is generally faster and provides better error diagnostics.
-   **Cross-Compilation:** Clang is inherently a cross-compiler. A single `clang` binary can compile for x86_64 and AArch64 just by changing the `--target` flag.

**Usage in `aake`:**
When `aake` invokes Meson, it sets `CC=prebuilts/clang/bin/clang`. For ARM64, it adds `--target=aarch64-linux-gnu`.

## 2. Swift Compiler (`swiftc`)

Swift is the primary language for ArkOS frameworks and the `arkrt` daemon. 

**Prebuilt Swift:**
The `prebuilts/Swift/` directory contains a pre-compiled Swift toolchain. This is a highly customized version of Swift:
-   **No Foundation:** ArkOS does not use Apple's `Foundation` framework to avoid heavy dependencies and Objective-C runtime overhead.
-   **Static Stdlib:** The Swift standard library is compiled statically into `arkrt` or dynamically provided in the `sys.img`.

## 3. NASM (Netwide Assembler)

NASM is used exclusively for the x86_64 `bootloader.asm` and `stage2.asm`. It translates the raw Intel-syntax assembly into flat binary files or ELF objects that are later linked into the 512-byte MBR sector.

## 4. Host Python3

Python 3 is used as a scripting glue for non-compilation tasks. Specifically, it drives the Verified Boot signing process. `vendor/verify/sign.py` uses Python's `hashlib` and cryptographic libraries to generate the RSA signatures appended to the partition images.
