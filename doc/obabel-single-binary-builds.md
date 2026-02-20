# obabel Single-Binary Builds

This repository now includes a release workflow and local scripts focused on shipping the `obabel` CLI as a single executable per platform:

- Linux: `obabel-linux-<arch>`
- macOS: `obabel-macos-<arch>`
- Windows: `obabel-windows-<arch>.exe`

## GitHub Release CI

Workflow file:

- `.github/workflows/release_obabel_single_binary.yml`

How it works:

1. Builds on `ubuntu-latest`, `macos-latest`, and `windows-latest`.
2. Uses static Open Babel build mode (`BUILD_SHARED=OFF`) and only builds target `obabel`.
3. Uploads binaries as artifacts, then publishes them to a GitHub Release tag.
4. Generates and uploads `SHA256SUMS.txt`.

Triggers:

- Tag push: `v*` (for example `v3.1.1`)
- Manual run: `workflow_dispatch` with input `tag`

## Local Build (Host OS)

### Linux / macOS

Prerequisites:

- `cmake`
- `ninja`
- compiler toolchain (`gcc/g++` or `clang`)
- development headers for optional dependencies used by your distro setup

Command:

```bash
bash scripts/release/build_obabel_standalone.sh
```

Output:

- `dist/obabel-linux-<arch>` on Linux
- `dist/obabel-macos-<arch>` on macOS

### Windows (PowerShell)

Prerequisites:

- Visual Studio Build Tools (MSVC)
- `cmake`
- `ninja`

Command:

```powershell
scripts/release/build_obabel_standalone.ps1
```

Output:

- `dist/obabel-windows-<arch>.exe`

## Local Linux Build via Docker

Use Docker to build Linux artifacts reproducibly from any host with Docker installed:

```bash
bash scripts/release/docker_build_linux.sh
```

This builds a local image from `scripts/release/Dockerfile.linux`, then runs:

- `scripts/release/build_obabel_standalone.sh`

inside the container and writes artifacts to:

- `dist/`

## Quick Smoke Tests

After building:

```bash
dist/obabel-linux-<arch> -V
echo "CCO" | dist/obabel-linux-<arch> -ismi -oinchi
```

Windows equivalent:

```powershell
.\dist\obabel-windows-x86_64.exe -V
"CCO" | .\dist\obabel-windows-x86_64.exe -ismi -oinchi
```
