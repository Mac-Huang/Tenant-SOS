#!/bin/bash

# Tenant SOS - Build and Run Script
# This script builds and runs the app in the simulator from terminal

set -e  # Exit on error

echo "🚀 Building Tenant SOS..."
cd /Users/Patron/Desktop/develop/Tenant-SOS/Tenant-SOS

# Build the app
xcodebuild -scheme "Tenant-SOS" \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    build \
    2>&1 | grep -E "(Succeeded|Failed|error:|Building|==)" || true

echo ""
echo "📱 Installing app on simulator..."

# Boot simulator if needed
xcrun simctl boot "iPhone 17" 2>/dev/null || true
sleep 2

# Uninstall old version
xcrun simctl uninstall "iPhone 17" com.tenantsos.app 2>/dev/null || true
sleep 1

# Install new version
xcrun simctl install "iPhone 17" \
    "/Users/Patron/Library/Developer/Xcode/DerivedData/Tenant-SOS-dbaemxptzqdnsgbzopkpncwxvkmh/Build/Products/Debug-iphonesimulator/Tenant-SOS.app"

echo ""
echo "🎉 Launching Tenant SOS..."

# Launch the app
xcrun simctl launch "iPhone 17" com.tenantsos.app

echo ""
echo "✅ App is running!"
echo "   Open Simulator.app to see it"

# Open Simulator
open -a Simulator
