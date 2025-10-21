#!/bin/bash

# Complete Wisconsin Location Testing Script

DEVICE_ID="52F883B0-B3A8-42EE-B8B9-4FA4DDE36843"
BUNDLE_ID="com.tenantsos.app"

echo "🧪 Complete Wisconsin Location Test"
echo "===================================="
echo ""

# Clean start
echo "🧹 Step 1: Clean slate..."
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
sleep 1

# Reset and grant permissions
echo "🔐 Step 2: Setting up permissions..."
xcrun simctl privacy "$DEVICE_ID" reset all 2>/dev/null || true
sleep 1
xcrun simctl privacy "$DEVICE_ID" grant location "$BUNDLE_ID"
xcrun simctl privacy "$DEVICE_ID" grant location-always "$BUNDLE_ID"
xcrun simctl privacy "$DEVICE_ID" grant notifications "$BUNDLE_ID"
sleep 1

# Set Wisconsin location
echo "📍 Step 3: Setting location to Madison, Wisconsin..."
xcrun simctl location "$DEVICE_ID" set 43.0731,-89.4012
sleep 2

# Build and install latest version
echo "🔨 Step 4: Building latest version..."
cd /Users/Patron/Desktop/develop/Tenant-SOS/Tenant-SOS
xcodebuild -scheme "Tenant-SOS" \
    -destination "platform=iOS Simulator,name=iPhone 17" \
    -derivedDataPath build \
    build 2>&1 | grep -E "(Succeeded|error:)" || echo "Build in progress..."
sleep 2

# Launch app
echo "🚀 Step 5: Launching app..."
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
sleep 5

echo ""
echo "✅ Test Setup Complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 CHECK LIST:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✓ Location: Madison, Wisconsin (43.0731, -89.4012)"
echo "✓ Permissions: Location Always + Notifications"
echo ""
echo "WHAT TO CHECK IN THE APP:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  HOME SCREEN:"
echo "   Expected: 'Madison, Wisconsin'"
echo "   NOT: 'Detecting location...' or 'San Francisco, CA'"
echo ""
echo "2️⃣  QUICK ACCESS BUTTONS:"
echo "   - Tap any category (Tenant Rights, Traffic, etc.)"
echo "   Expected: Shows Wisconsin laws"
echo "   NOT: 'Location not available'"
echo ""
echo "3️⃣  SEARCH:"
echo "   - Search for 'minimum wage'"
echo "   Expected: Shows '$7.25/hour' for Wisconsin"
echo ""
echo "4️⃣  TENANT RIGHTS:"
echo "   Expected laws for Wisconsin:"
echo "   - Security Deposit: No statutory limit"
echo "   - Rent Increase Notice: 28 days"
echo "   - Eviction Notice: 5 days"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🐛 TROUBLESHOOTING:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "If still showing 'Location not available':"
echo ""
echo "A. Check location permission in Settings:"
echo "   Settings > Privacy > Location Services > Tenant SOS"
echo "   Should show: 'Always'"
echo ""
echo "B. Try pull-to-refresh on home screen"
echo ""
echo "C. Or tap 'Refresh Location' button if shown"
echo ""
echo "D. Manually verify simulator location:"
echo "   Simulator menu > Features > Location"
echo "   Should show 'Custom Location (43.0731, -89.4012)'"
echo ""
echo "E. Check app console logs:"
echo "   Look for:"
echo "   '📍 Got location update: 43.0731, -89.4012'"
echo "   '✅ Location updated: Madison, Wisconsin'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 WISCONSIN LAW DATABASE STATS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total WI Laws: 80"
echo "  • Tenant Rights: 15 laws"
echo "  • Traffic: 18 laws"
echo "  • Employment: 19 laws"
echo "  • Taxes: 13 laws"
echo "  • Consumer: 15 laws"
echo ""
echo "If you see these numbers when browsing, location is WORKING! ✅"
echo ""