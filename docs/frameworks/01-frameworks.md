# ArkOS Frameworks Architecture

The `frameworks/` directory in ArkOS houses the higher-level libraries and APIs that application developers use to interface with the operating system. Unlike generic Linux distributions that rely on a scattered ecosystem of GTK, Qt, and raw POSIX APIs, ArkOS provides a cohesive, unified framework layer written primarily in Swift.

## Design Philosophy

ArkOS Frameworks are designed around three core principles:
1. **Swift-First:** The primary API surface is Swift. This allows for safe, concurrent, and expressive UI and system programming.
2. **Declarative UI:** The UI framework heavily borrows concepts from SwiftUI and declarative paradigms.
3. **Privilege Separation:** Frameworks communicate with the underlying `arkrt` daemon via strict RPC. Applications linking against these frameworks do not get direct raw hardware access.

## Key Frameworks

### 1. ArkUI (Declarative User Interface)
ArkUI is the standard toolkit for building graphical applications in ArkOS.
- **Backend:** It uses a highly optimized Wayland client backend.
- **Rendering:** All rendering is hardware-accelerated via Vulkan or OpenGL ES (depending on the target, e.g., GLES on RPi4).
- **Widgets:** Provides standard, accessible controls (Buttons, Lists, TextFields) that automatically adapt to the system's global theme and accessibility settings.

### 2. ArkData (Persistence and IPC)
Applications in ArkOS are sandboxed. ArkData provides a secure, brokered way to store data and communicate.
- **Key-Value Store:** A fast, atomic preferences store.
- **IPC Broker:** Instead of raw sockets, applications define Swift Protocols. The ArkData compiler generates the necessary RPC stubs to serialize and deserialize method calls between the app and system services.

### 3. ArkMedia
Handles audio and video playback, interfacing with the vendor-specific hardware decoders (e.g., V4L2 mem2mem on AArch64). It also integrates with the DRM (Widevine) subsystems when required by vendor partitions.

## Building with Frameworks

When an application is compiled for ArkOS (often using the `aake` build tool), it automatically links against the sysroot's framework stubs.

```swift
import ArkUI
import ArkData

@main
struct MyApp: App {
    var body: some Scene {
        Window("My Application") {
            VStack {
                Text("Hello, ArkOS!")
            }
        }
    }
}
```

The `aake` compiler ensures that the binary is statically linked with necessary shims but dynamically links the heavy frameworks from `/system/frameworks/` at runtime, reducing binary bloat and allowing the OS to update the UI look-and-feel without requiring app recompilation.
