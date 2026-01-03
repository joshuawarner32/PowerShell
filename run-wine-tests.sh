#!/bin/bash
# Convenience script to run PowerShell test suite in Wine

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PWSH_DIR="${SCRIPT_DIR}/out/windows/powershell-win7-x64"

if [ ! -d "$PWSH_DIR" ]; then
    echo "Error: PowerShell Windows build not found at $PWSH_DIR"
    echo "Please run ./build-windows.sh first"
    exit 1
fi

# Check if Wine container exists
if ! docker images | grep -q "powershell-wine-test"; then
    echo "Building Wine test container..."
    docker build -t powershell-wine-test -f Dockerfile.wine-test .
fi

docker run --rm \
    -v "${PWSH_DIR}:/powershell-test/powershell-win7-x64:ro" \
    -v "${SCRIPT_DIR}/wine-test-suite.ps1:/test-script.ps1:ro" \
    -e WINEDEBUG=-all \
    -e XDG_RUNTIME_DIR=/tmp \
    powershell-wine-test \
    unbuffer wine64 /powershell-test/powershell-win7-x64/pwsh.exe --NonInteractive -NoProfile -ExecutionPolicy Bypass -File /test-script.ps1
