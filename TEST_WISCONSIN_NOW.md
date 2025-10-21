# Quick Test: Set Location to Wisconsin

## Set Simulator Location to Wisconsin

### In Xcode Simulator:

1. **With App Running:**
   - Make sure the app is running
   - In Simulator menu: **Features > Location > Custom Location**

2. **Enter Wisconsin Coordinates (Madison):**
   - **Latitude:** 43.0731
   - **Longitude:** -89.4012
   - Click OK

3. **What Should Happen:**
   - App should detect you're in Wisconsin
   - Home screen should update from "San Francisco, California" to "Madison, Wisconsin"
   - If you had a different state before, you'll get a notification

## Alternative Wisconsin Locations:

**Milwaukee:**
- Latitude: 43.0389
- Longitude: -87.9065

**Green Bay:**
- Latitude: 44.5133
- Longitude: -88.0133

## Troubleshooting:

**If location doesn't update:**
1. Make sure you allowed location permissions during onboarding
2. Try pulling down to refresh on the home screen
3. Try closing and reopening the app
4. In Settings app > Privacy > Location Services > Tenant SOS > Set to "Always"

**To test state change notification:**
1. First set to another state (e.g., Illinois: 41.8781, -89.3985)
2. Background the app (press Home button)
3. Then change to Wisconsin coordinates
4. You should get a notification!

## What's Fixed:
- ✅ Removed default San Francisco location
- ✅ App now requests actual location on startup
- ✅ Home screen shows "Detecting location..." until GPS is ready
- ✅ Location updates immediately when changed in simulator