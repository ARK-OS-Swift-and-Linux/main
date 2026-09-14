# Aake Ninja Generation

With the architectural overhaul of `aake`, it now directly parses `.aake.ark` files (or `aake.ark` files if `VISIBLE_BLUEPRINT` is set to true) and generates optimized, raw Ninja build syntax.

## Subdirectory Ninja Structure

Instead of creating one monolithic `build.ninja` file containing thousands of rules and build targets, `aake` generates localized `.ninja` subdirectories within each source directory that contains a valid `.aake.ark` configuration.

### Example Directory Tree
```
src/
  ├── .aake.ark
  ├── main.c
  ├── utils.c
  └── .ninja/
      └── build.ninja
```

### Localized `build.ninja`

The generated `build.ninja` files inside these `.ninja/` subdirectories only contain the build directives relevant to their specific target. 

By writing to these localized caches, `aake` avoids regenerating the entire repository's build graph when switching contexts, functioning similarly to Android's localized `m <module>` behavior but strictly powered by localized Ninja caches.

## Master Orchestrator

In the root build directory (`builddir/`), `aake` generates a master `build.ninja` file. This master file acts as the primary orchestrator.

1. **Variables & Rules**: The master file sets global tools (`cc`, `ar`, `cflags`, `ldflags`), pulling the sysroot and target arguments from the environment or cross-file configuration automatically.
2. **Subninja Declarations**: For every localized `.ninja/build.ninja` discovered during the recursive tree walk, the master file includes a `subninja` directive.

```ninja
ninja_required_version = 1.8.2

cc = /home/arkos/repo/arkos/prebuilts/clang/bin/clang
cflags = -target x86_64-linux-musl --sysroot=/home/arkos/repo/arkos/prebuilts/... -fPIC

rule cc
  command = $cc $cflags -c $in -o $out
  description = CC $out

subninja ../src/ui/.ninja/build.ninja
subninja ../src/core/.ninja/build.ninja
```

When Ninja is invoked from `builddir`, it reads this master file, loads all the localized build rules, and builds the dependency graph with maximum concurrency.
