# Welcome to ARK-OS

Welcome to the primary repository for **ARK-OS**! 

(I am currently working on my own version of gogs to protect validation and proper following of the rules below)

> [!NOTE]
> This root file contains the repository rules and contribution guidelines. For technical documentation and system information, please refer to the primary [README.md](./arkos/README.md) inside the `arkos` folder.

---

## 📋 Repository Rules & Guidelines

To maintain the integrity of this project, all contributors must strictly adhere to the following rules. Failure to comply will result in repository deletion or access revocation.

* **Forking policy:** You are permitted to fork this repository only.
* **Naming convention:** Your forked repository **must** be named exactly `ARK-OS`. Repositories using any other name will be automatically deleted.
* **Content restrictions:** Hosting alternative repositories or malicious content under this project umbrella is strictly prohibited.
* **Resource limits:** Users are granted permission to create exactly one (1) repository.
* **Profile verification:** You must provide a valid username and a functional email address when signing in or contributing.
* **Security & reporting:** If you have questions, notice off-topic activity, or spot suspicious content, immediately contact the project owner at [aarav.kharade1234@gmail.com](mailto:arkosgogs@gmail.com).

---

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
