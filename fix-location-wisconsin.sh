#!/bin/bash

# Complete fix for Wisconsin location detection

DEVICE_ID="52F883B0-B3A8-42EE-B8B9-4FA4DDE36843"
BUNDLE_ID="com.tenantsos.app"

echo "🔧 Fixing Location Detection for Wisconsin"
echo "============================================"
echo ""

# Step 1: Kill the app if running
echo "1️⃣  Stopping app..."
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
sleep 1

# Step 2: Reset location and privacy
echo "2️⃣  Resetting location permissions..."
xcrun simctl privacy "$DEVICE_ID" reset location 2>/dev/null || true
sleep 1

# Step 3: Grant location permissions
echo "3️⃣  Granting location permissions..."
xcrun simctl privacy "$DEVICE_ID" grant location "$BUNDLE_ID"
xcrun simctl privacy "$DEVICE_ID" grant location-always "$BUNDLE_ID"
sleep 1

# Step 4: Set location to Wisconsin
echo "4️⃣  Setting location to Madison, Wisconsin..."
xcrun simctl location "$DEVICE_ID" set 43.0731,-89.4012
sleep 2

# Step 5: Launch the app
echo "5️⃣  Launching app..."
xcrun simctl launch --console "$DEVICE_ID" "$BUNDLE_ID" &
APP_PID=$!
sleep 3

echo ""
echo "✅ Setup complete!"
echo ""
echo "📍 Location: Madison, Wisconsin (43.0731, -89.4012)"
echo "🔐 Permissions: Location Always granted"
echo ""
echo "Expected behavior:"
echo "  ✓ Home screen should show 'Madison, Wisconsin'"
echo "  ✓ Quick access button should show WI laws"
echo "  ✓ Location should NOT say 'not available'"
echo ""
echo "If still showing 'location not available':"
echo "  1. Open Settings app in simulator"
echo "  2. Privacy & Security > Location Services"
echo "  3. Find 'Tenant SOS'"
echo "  4. Ensure it says 'Always'"
echo ""
echo "Press Ctrl+C to stop watching logs"
sleep 2

# Wait for app to start and show logs
wait $APP_PID 2>/dev/null