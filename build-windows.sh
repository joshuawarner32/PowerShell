#!/bin/bash
# Cross-compile PowerShell for Windows from Linux using Docker

set -e

echo "=== Building PowerShell for Windows x64 ==="
echo ""

if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    exit 1
fi

echo "Building Docker image..."
docker build -t powershell-windows-cross-build -f Dockerfile.windows-cross .

mkdir -p out/windows

echo ""
echo "Running build in Docker container..."
docker run --rm \
    -v "$(pwd):/powershell" \
    -v "$(pwd)/out/windows:/output" \
    powershell-windows-cross-build \
    -c '
        set -e
        cd /powershell
        
        # Workaround: Remove unavailable MyGet packages from project file
        cp src/powershell-unix/powershell-unix.csproj src/powershell-unix/powershell-unix.csproj.backup
        grep -v PSDesiredStateConfiguration src/powershell-unix/powershell-unix.csproj.backup | grep -v PowerShellHelpFiles > src/powershell-unix/powershell-unix.csproj
        
        # Use simplified nuget.config (nuget.org only)
        cp nuget.config nuget.config.backup
        cp nuget.config.windows-cross nuget.config
        
        pwsh -NoProfile -Command "
            Import-Module ./build.psm1
            Start-PSBootstrap -Package -NoSudo -Force
            Start-PSBuild -Configuration Release -Runtime win7-x64 -Restore
            \$options = Get-PSOptions
            \$outputDir = Split-Path \$options.Output
            Copy-Item -Path \$outputDir -Destination /output/powershell-win7-x64 -Recurse -Force
        "
        
        # Restore original files
        mv src/powershell-unix/powershell-unix.csproj.backup src/powershell-unix/powershell-unix.csproj
        mv nuget.config.backup nuget.config
    '

echo ""
echo "=== Build completed successfully! ==="
echo "Output: $(pwd)/out/windows/powershell-win7-x64"
echo ""
echo "Copy to Windows and run pwsh.exe"
