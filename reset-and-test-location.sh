#!/bin/bash

# Complete location testing script for Tenant SOS

DEVICE_ID="52F883B0-B3A8-42EE-B8B9-4FA4DDE36843"
BUNDLE_ID="com.tenantsos.app"

echo "🔄 Resetting and Testing Location for Tenant SOS"
echo "=================================================="
echo ""

# Step 1: Reset location privacy settings
echo "1️⃣  Resetting location & privacy settings..."
xcrun simctl privacy "$DEVICE_ID" reset location 2>/dev/null || true
sleep 1

# Step 2: Grant location permission
echo "2️⃣  Granting location permission..."
xcrun simctl privacy "$DEVICE_ID" grant location "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant location-always "$BUNDLE_ID" 2>/dev/null || true
sleep 1

# Step 3: Terminate the app if running
echo "3️⃣  Terminating app..."
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
sleep 1

# Step 4: Set location to Wisconsin
echo "4️⃣  Setting location to Wisconsin (Madison)..."
xcrun simctl location "$DEVICE_ID" set 43.0731,-89.4012
sleep 1

# Step 5: Launch the app
echo "5️⃣  Launching Tenant SOS..."
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
sleep 2

echo ""
echo "✅ Setup complete!"
echo ""
echo "📍 Current Location: Madison, Wisconsin (43.0731, -89.4012)"
echo ""
echo "🧪 What to verify in the app:"
echo "   1. Home screen should show 'Madison, Wisconsin'"
echo "   2. NOT 'San Francisco, California'"
echo "   3. Pull down to refresh should update location"
echo ""
echo "🔧 If still showing wrong location:"
echo "   - Try force-closing the app (swipe up in app switcher)"
echo "   - Run this script again"
echo "   - Or manually set location in Simulator:"
echo "     Features > Location > Custom Location > 43.0731, -89.4012"