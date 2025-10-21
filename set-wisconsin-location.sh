#!/bin/bash

# Set Simulator Location to Wisconsin (Madison)
# This script helps test the location feature

echo "📍 Setting simulator location to Wisconsin (Madison)..."

# Madison, Wisconsin coordinates
LAT="43.0731"
LON="-89.4012"

# Find the running simulator device
DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ No booted simulator found. Please run the app first."
    exit 1
fi

echo "   Device ID: $DEVICE_ID"
echo "   Location: Madison, WI ($LAT, $LON)"

# Set the location (note: coordinates must be provided together)
xcrun simctl location "$DEVICE_ID" set "$LAT,$LON"

echo "✅ Location set to Wisconsin!"
echo ""
echo "The app should now detect you're in Wisconsin."
echo "If location doesn't update:"
echo "  1. Pull down to refresh in the app"
echo "  2. Or restart the app"