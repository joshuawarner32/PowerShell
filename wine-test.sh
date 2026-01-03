#!/bin/bash
# Helper script to test PowerShell Windows build in Wine
# This script runs PowerShell in a Wine container for testing and debugging

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PWSH_DIR="${SCRIPT_DIR}/out/windows/powershell-win7-x64"

if [ ! -d "$PWSH_DIR" ]; then
    echo "Error: PowerShell Windows build not found at $PWSH_DIR"
    echo "Please run ./build-windows.sh first"
    exit 1
fi

if ! docker images | grep -q "powershell-wine-test"; then
    docker build -t powershell-wine-test -f Dockerfile.wine-test .
fi

COMMAND="${@:-pwd}"

docker run --rm \
    -v "${PWSH_DIR}:/powershell-test/powershell-win7-x64:ro" \
    -e WINEDEBUG=-all \
    -e XDG_RUNTIME_DIR=/tmp \
    powershell-wine-test \
    unbuffer wine64 /powershell-test/powershell-win7-x64/pwsh.exe --NonInteractive -Command "$COMMAND"
