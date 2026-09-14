# Aake Ninja UI Wrapper

After `aake` generates `meson.build` files and invokes `meson setup`, it executes `ninja` to perform the actual compilation. However, raw `ninja` output can be dense and difficult to read, especially during large parallel builds of the kernel, Swift frameworks, and C bootloaders.

## `ninja_ui.c`

The `aake` system includes a specialized UI wrapper for Ninja, implemented in `ninja_ui.c`.

### Interception Mechanism

1.  `aake` spawns `ninja` as a child process using `fork()` and `exec()`.
2.  It sets up a pseudo-terminal (PTY) or pipes `stdout` and `stderr` from the `ninja` process back to the parent `aake` process.
3.  `ninja_ui.c` reads the output stream line-by-line. It looks for the standard Ninja progress markers (e.g., `[10/500] Compiling C object...`).

### The ArkOS UI

Once the output is intercepted, `ninja_ui.c` suppresses the raw output and instead draws a beautiful, clear progress bar at the bottom of the terminal using ANSI escape codes.

-   **Progress Bar:** Shows a smooth percentage.
-   **Current Task:** Displays the name of the file currently being compiled.
-   **Error Handling:** If `ninja` exits with a non-zero status or outputs the word `error:`, the UI interceptor immediately dumps the captured buffer to the screen so the developer can see exactly what failed without scrolling through hundreds of lines of successful compilation logs.

This ensures that building ArkOS feels polished and user-friendly, aligning with the operating system's overall design philosophy.
