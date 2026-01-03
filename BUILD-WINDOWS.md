# Cross-Compiling PowerShell for Windows from Linux

This guide explains how to cross-compile PowerShell for Windows from Linux using Docker.

## Prerequisites

- Docker installed and running
- At least 4GB of free disk space
- Internet connection (first build only)

## Quick Start

```bash
./build-windows.sh
```

This will:
1. Build a Docker image with all necessary dependencies
2. Cross-compile PowerShell for Windows x64 (Release configuration)
3. Output the binaries to `out/windows/powershell-win7-x64/`

The first build takes 15-20 minutes. Subsequent builds are faster.

## Output

The compiled binaries are placed in:
```
out/windows/powershell-win7-x64/
```

## Using the Build on Windows

1. Copy the output directory to a Windows machine
2. Run `pwsh.exe` to start PowerShell

## How It Works

The build uses Docker to create an isolated Ubuntu 18.04 environment with:
- .NET Core SDK 2.1.808 (as specified in `global.json`)
- PowerShell for running build scripts
- Build tools (cmake, make, g++, etc.)
- Mono for certificate management

### Workaround for Defunct MyGet Feeds

This PowerShell version originally depended on packages from MyGet feeds that no longer exist:
- `PowerShellHelpFiles` - Help documentation files  
- `PSDesiredStateConfiguration` - DSC module

The build script automatically excludes these packages. The resulting executable works fine but:
- No built-in help files (use `Get-Help -Online` instead)
- No DSC module (can be installed separately if needed)

## Troubleshooting

### Docker Permission Denied

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Out of Disk Space

```bash
docker system prune -a
```

### Rebuild Docker Image

```bash
docker rmi powershell-windows-cross-build
./build-windows.sh
```

## Technical Details

The build process:
1. Creates a Docker image with all dependencies
2. Mounts the PowerShell source code into the container
3. Temporarily modifies `nuget.config` to use only nuget.org
4. Removes unavailable package references from the project file
5. Runs `Start-PSBootstrap` to install build dependencies
6. Runs `Start-PSBuild` with runtime identifier `win7-x64`
7. Copies the compiled output to the host

The `win7-x64` runtime is compatible with Windows 7, 8, 8.1, 10, 11, and Server versions.

## Files

- `Dockerfile.windows-cross` - Docker build environment definition
- `build-windows.sh` - Build script
- `nuget.config.windows-cross` - Simplified NuGet configuration (nuget.org only)
- `.dockerignore` - Docker context optimization
