#!/bin/bash

# Check location permission status for Tenant SOS app

DEVICE_ID="52F883B0-B3A8-42EE-B8B9-4FA4DDE36843"

echo "📱 Checking location permission for Tenant SOS..."
echo ""

# Get the app's privacy database
PRIVACY_DB="/Users/Patron/Library/Developer/CoreSimulator/Devices/$DEVICE_ID/data/Library/TCC/TCC.db"

if [ -f "$PRIVACY_DB" ]; then
    echo "🔍 Location Services Status:"
    sqlite3 "$PRIVACY_DB" "SELECT service, client, auth_value FROM access WHERE service='kTCCServiceLocation' AND client LIKE '%tenantsos%';" 2>/dev/null || echo "   No location permission records found"
else
    echo "⚠️  Privacy database not found"
fi

echo ""
echo "🎯 Current simulator location:"
xcrun simctl location "$DEVICE_ID" list 2>/dev/null || echo "   Unable to get current location"

echo ""
echo "💡 To grant location permission:"
echo "   1. Open Settings app in simulator"
echo "   2. Go to Privacy & Security > Location Services"
echo "   3. Find Tenant SOS"
echo "   4. Set to 'Always' or 'While Using the App'"