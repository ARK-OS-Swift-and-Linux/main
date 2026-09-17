# Welcome to ARK-OS

Welcome to the primary repository for **ARK-OS**! 

BUILD STATUS : FAILING

You can sync the repo via:
```bash
curl -fsSL https://raw.githubusercontent.com/ARK-OS-Swift-and-Linux/main/refs/heads/main/sync.sh | bash
```


## 🛠️ Architecture & Device Support

### Hardware Support
* **Official Support:** Raspberry Pi 4 Model B (ARM64)

### Supported Architectures
* **`x86_64`** — Stable / Available
* **`arm64` (aarch64)** — Stable / Available

### Compiler Toolchain
* All C/C++ compilation uses **Clang/LLVM** with target triples
* Swift compilation via `swiftc` with architecture-specific SDKs
* Android-style build environment (`source envsetup.sh` → `type arm64` → `make`)

*Disclaimer: Support provided by third-party or custom projects will not be officially recognized or supported by the core maintenance team.*
