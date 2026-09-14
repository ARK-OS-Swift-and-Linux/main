# ArkOS Service Management

ArkOS abandons traditional shell-script-based `init.d` or complex `systemd` unit files in favor of a declarative JSON-like format: `.serve` files. These are parsed and managed by the `ark.sys.service` module within `arkrt`.

## The `.serve` Format

A `.serve` file defines exactly how a daemon should run, its dependencies, and its security context.

```json
{
    "service_name": "net_daemon",
    "executable": "/system/bin/net_daemon",
    "args": ["--daemonize", "false"],
    "dependencies": ["hw_rng", "dbus_broker"],
    "restart_policy": "on-failure",
    "capabilities": ["CAP_NET_ADMIN", "CAP_NET_RAW"],
    "user": "network",
    "group": "network"
}
```

### Key Features

1.  **Strict Dependencies:** If `net_daemon` depends on `hw_rng`, `arkrt` will block the startup of `net_daemon` until the `hw_rng` service emits a "READY" signal over the ArkOS IPC bus.
2.  **No Forking:** Services must run in the foreground (`--daemonize false`). `arkrt` monitors the PID directly. If a service forks and exits, `arkrt` considers it dead and triggers the restart policy.
3.  **Capability Bounding:** The `capabilities` array uses Linux capabilities to drop root privileges. The `net_daemon` runs as the `network` user, but retains the ability to configure network interfaces (`CAP_NET_ADMIN`) without needing full `sudo` access.

## Service Lifecycle

1.  **Parsing:** During boot, `arkrt` reads all `.serve` files in `/system/services/`.
2.  **Graph Construction:** It builds a dependency DAG. Circular dependencies result in a fatal boot error (Kernel Panic).
3.  **Execution:** Services are spawned in parallel based on topological sorting.
4.  **Monitoring:** If a service with `restart_policy: on-failure` crashes, `arkrt` captures the exit code, logs a stack trace to `/var/log/arkrt.log`, and respawns it with exponential backoff.
