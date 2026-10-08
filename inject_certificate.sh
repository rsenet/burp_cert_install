#!/usr/bin/env bash
# Detect the Android API version of the connected device and run the matching
# certificate injection script.
#
# Usage: ./inject_certificate.sh
# With several devices connected, select one with: ANDROID_SERIAL=<serial> ./inject_certificate.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check that adb is available
if ! command -v adb >/dev/null 2>&1; then
    echo "[-] adb not found in PATH" >&2
    exit 1
fi

# Check that a device is reachable
if ! adb get-state >/dev/null 2>&1; then
    echo "[-] No device connected (or several devices: set ANDROID_SERIAL)" >&2
    exit 1
fi

# Get API version
API=$(adb shell getprop ro.build.version.sdk | tr -d '\r[:space:]')

if ! [[ "$API" =~ ^[0-9]+$ ]]; then
    echo "[-] Unable to detect API version (got: '$API')" >&2
    exit 1
fi

# Select the right script
if [ "$API" -le 23 ]; then
    SCRIPT="inject_certificate_before_API_23.sh"
elif [ "$API" -lt 34 ]; then
    SCRIPT="inject_certificate_before_API_34.sh"
else
    SCRIPT="inject_certificate_after_API_34.sh"
fi

echo "[+] API $API detected, running $SCRIPT"
bash "$SCRIPT_DIR/$SCRIPT"
