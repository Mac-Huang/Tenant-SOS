#!/bin/bash

DEVICE_ID="52F883B0-B3A8-42EE-B8B9-4FA4DDE36843"
BUNDLE_ID="com.tenantsos.app"

echo "🔍 Location Services Diagnostic"
echo "================================"
echo ""

echo "1️⃣ Checking if app is running..."
APP_STATUS=$(xcrun simctl launch --console "$DEVICE_ID" "$BUNDLE_ID" 2>&1 | grep -i "already running" || echo "not running")
if [[ $APP_STATUS == *"running"* ]]; then
    echo "   ✓ App is running"
else
    echo "   ⚠ App not running - launching..."
    xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
    sleep 3
fi
echo ""

echo "2️⃣ Current simulator location..."
LOCATION=$(xcrun simctl location "$DEVICE_ID" list 2>&1)
echo "$LOCATION"
echo ""

echo "3️⃣ Setting Wisconsin location..."
xcrun simctl location "$DEVICE_ID" set 43.0731,-89.4012
sleep 2
echo "   ✓ Set to Madison, WI (43.0731, -89.4012)"
echo ""

echo "4️⃣ Checking location permissions..."
PRIVACY_DB="/Users/Patron/Library/Developer/CoreSimulator/Devices/$DEVICE_ID/data/Library/TCC/TCC.db"
if [ -f "$PRIVACY_DB" ]; then
    PERMS=$(sqlite3 "$PRIVACY_DB" "SELECT service, client, auth_value, auth_reason FROM access WHERE client LIKE '%tenantsos%' OR client LIKE '%Tenant%';" 2>/dev/null)
    if [ -z "$PERMS" ]; then
        echo "   ⚠ No permissions found in database"
        echo "   → Granting permissions..."
        xcrun simctl privacy "$DEVICE_ID" grant location "$BUNDLE_ID"
        xcrun simctl privacy "$DEVICE_ID" grant location-always "$BUNDLE_ID"
        echo "   ✓ Permissions granted"
    else
        echo "   ✓ Permissions found:"
        echo "$PERMS" | while read line; do
            echo "     $line"
        done
    fi
else
    echo "   ⚠ Privacy database not found"
fi
echo ""

echo "5️⃣ Triggering location update..."
echo "   → Terminating app..."
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null
sleep 1
echo "   → Relaunching..."
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
sleep 3
echo "   ✓ App relaunched"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 DIAGNOSTIC COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. Check the app now:"
echo "   → Home screen should show 'Madison, Wisconsin'"
echo "   → Quick Access should show WI laws"
echo ""
echo "2. If still showing 'Location Not Detected':"
echo ""
echo "   a) Open Settings app in simulator"
echo "   b) Go to: Privacy & Security > Location Services"
echo "   c) Scroll to find 'Tenant SOS'"
echo "   d) Tap it and select 'Always'"
echo ""
echo "3. Try the refresh button:"
echo "   → Tap 'Refresh Location' button in the app"
echo ""
echo "4. Check console logs:"
echo "   Look for these debug messages:"
echo "   • '🚀 LocationManager init'"
echo "   • '📍 Got location update'"
echo "   • '✅ Location updated: Madison, Wisconsin'"
echo ""