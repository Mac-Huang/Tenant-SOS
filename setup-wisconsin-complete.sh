#!/bin/bash

# Complete Wisconsin setup script

DEVICE_ID="52F883B0-B3A8-42EE-B8B9-4FA4DDE36843"
BUNDLE_ID="com.tenantsos.app"

echo "🔧 Complete Wisconsin Setup"
echo "============================"
echo ""

# Step 1: Clean start
echo "1. Stopping app..."
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
sleep 1

# Step 2: Reset location & privacy
echo "2. Resetting location permissions..."
xcrun simctl privacy "$DEVICE_ID" reset location 2>/dev/null || true
sleep 1

# Step 3: Grant permissions
echo "3. Granting location permissions..."
xcrun simctl privacy "$DEVICE_ID" grant location "$BUNDLE_ID"
xcrun simctl privacy "$DEVICE_ID" grant location-always "$BUNDLE_ID"
sleep 1

# Step 4: Set Wisconsin location
echo "4. Setting location to Madison, Wisconsin..."
xcrun simctl location "$DEVICE_ID" set 43.0731,-89.4012
sleep 2

# Step 5: Launch app
echo "5. Launching app..."
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
sleep 5

echo ""
echo "✅ Setup Complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 NOW CHECK THE APP:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Home screen should show:"
echo "   'Madison, Wisconsin'"
echo ""
echo "2. Tap a Quick Access button"
echo ""
echo "3. If you see 'Location Not Detected':"
echo "   → Tap the 'Refresh Location' button"
echo "   → It should show 'Refreshing...'"
echo "   → Wait 2-3 seconds"
echo "   → Should then show Wisconsin laws"
echo ""
echo "4. The button now:"
echo "   ✓ Shows loading spinner when pressed"
echo "   ✓ Requests permission if needed"
echo "   ✓ Shows helpful error if permission denied"
echo "   ✓ Restarts location monitoring"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐛 IF STILL NOT WORKING:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Manual permission check:"
echo "1. Open Settings app in simulator"
echo "2. Privacy & Security > Location Services"
echo "3. Make sure Location Services is ON"
echo "4. Scroll to 'Tenant SOS'"
echo "5. Select 'Always'"
echo ""
echo "Then restart this script."
echo ""