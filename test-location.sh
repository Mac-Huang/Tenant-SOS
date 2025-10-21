#!/bin/bash

# Test location changes for Tenant SOS app

echo "🧪 Testing Location Feature for Tenant SOS"
echo "==========================================="
echo ""

# Find device ID
DEVICE_ID="52F883B0-B3A8-42EE-B8B9-4FA4DDE36843"

# Test 1: Set to California
echo "📍 Test 1: Setting location to California (San Francisco)..."
xcrun simctl location "$DEVICE_ID" set 37.7749,-122.4194
sleep 3
echo "   ✓ Location set to San Francisco, CA"
echo ""

# Test 2: Set to Wisconsin
echo "📍 Test 2: Setting location to Wisconsin (Madison)..."
xcrun simctl location "$DEVICE_ID" set 43.0731,-89.4012
sleep 3
echo "   ✓ Location set to Madison, WI"
echo "   🔔 You should see a notification about entering Wisconsin"
echo ""

# Test 3: Set to Illinois
echo "📍 Test 3: Setting location to Illinois (Chicago)..."
xcrun simctl location "$DEVICE_ID" set 41.8781,-87.6298
sleep 3
echo "   ✓ Location set to Chicago, IL"
echo "   🔔 You should see a notification about entering Illinois"
echo ""

# Test 4: Set to Texas
echo "📍 Test 4: Setting location to Texas (Austin)..."
xcrun simctl location "$DEVICE_ID" set 30.2672,-97.7431
sleep 3
echo "   ✓ Location set to Austin, TX"
echo "   🔔 You should see a notification about entering Texas"
echo ""

echo "✅ Location tests complete!"
echo ""
echo "Check the app to verify:"
echo "  1. Home screen shows current location"
echo "  2. Notifications appear when changing states"
echo "  3. Law differences are shown in notifications"