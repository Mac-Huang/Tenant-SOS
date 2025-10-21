# Manual Location Testing Guide

## The Issue
App shows "Location Not Detected" even though you're in Wisconsin.

## Step-by-Step Fix

### 1. Check Simulator Location
**In Simulator Menu:**
- Click: `Features > Location > Custom Location...`
- Enter:
  - **Latitude:** `43.0731`
  - **Longitude:** `-89.4012`
- Click OK

✅ This sets the simulator to Madison, Wisconsin

---

### 2. Check Location Permissions

**Open Settings App in Simulator:**

1. Tap `Settings` icon
2. Scroll down and tap `Privacy & Security`
3. Tap `Location Services`
4. Make sure Location Services toggle is **ON** (green)
5. Scroll down to find `Tenant SOS`
6. Tap `Tenant SOS`
7. Select **`Always`** (not "While Using the App")

✅ This grants full location access

---

### 3. Restart Tenant SOS App

**Close and Reopen:**

1. Swipe up from bottom (or double-press home button)
2. Find Tenant SOS app card
3. Swipe up to close it
4. Tap Tenant SOS icon to reopen

✅ Fresh start with new location and permissions

---

### 4. What You Should See

#### Home Screen
```
📍 Current Location
Madison, Wisconsin
Laws and regulations for this area are now active
```

#### Quick Access
- Tap any category (Tenant Rights, Traffic, etc.)
- Should show Wisconsin laws
- **NOT** "Location Not Detected"

---

### 5. If Still Not Working

#### Try Refresh Button
If you see "Location Not Detected":
- There should be a blue **"Refresh Location"** button
- Tap it to manually trigger location update

#### Pull to Refresh
On the home screen:
- Pull down from top
- Release to refresh
- Wait a moment for location to update

---

### 6. Debug Information

#### What the Console Should Show
If you can see Xcode console, look for:

```
🚀 LocationManager init - Authorization status: 3
✅ Have permission, starting monitoring
📍 Starting location updates...
📍 Got location update: 43.0731, -89.4012
🔄 Starting geocoding request...
✅ Geocoding response received
📦 Placemark details:
   - administrativeArea: Wisconsin
   - locality: Madison
✅ Location updated: Madison, Wisconsin
   → currentState is now: Optional("Wisconsin")
   → currentCity is now: Optional("Madison")
```

#### What Indicates a Problem

**No location updates:**
```
🚀 LocationManager init - Authorization status: 0 or 2
⛔ Cannot start monitoring - no permission
```
→ Means permissions not granted

**Gets coordinates but no geocoding:**
```
📍 Got location update: 43.0731, -89.4012
(then nothing)
```
→ Geocoding might be failing (network issue?)

---

### 7. Alternative: Use Search

If location detection won't work:

1. Tap `Search` tab
2. Change state dropdown from "All States" to **"Wisconsin"**
3. Browse laws by category
4. All 80 Wisconsin laws are available!

---

### 8. Common Issues

#### Issue: Authorization Status = 0
**Meaning:** Location permission not determined
**Fix:** Go to Settings and grant permission

#### Issue: Authorization Status = 2
**Meaning:** Location permission denied
**Fix:** Go to Settings > Privacy > Location Services > Tenant SOS > Allow

#### Issue: No coordinates received
**Meaning:** Simulator location not set
**Fix:** Features > Location > Custom Location

#### Issue: Gets coordinates but shows "Unknown"
**Meaning:** Geocoding failed
**Fix:**
- Check simulator has internet connection
- Try restarting simulator
- Or use Search tab workaround

---

## Quick Commands (if using terminal)

```bash
# Set location
xcrun simctl location 52F883B0-B3A8-42EE-B8B9-4FA4DDE36843 set 43.0731,-89.4012

# Grant permission
xcrun simctl privacy 52F883B0-B3A8-42EE-B8B9-4FA4DDE36843 grant location com.tenantsos.app

# Reset and start fresh
xcrun simctl privacy 52F883B0-B3A8-42EE-B8B9-4FA4DDE36843 reset location
xcrun simctl privacy 52F883B0-B3A8-42EE-B8B9-4FA4DDE36843 grant location com.tenantsos.app
xcrun simctl location 52F883B0-B3A8-42EE-B8B9-4FA4DDE36843 set 43.0731,-89.4012
```

---

## Expected: Wisconsin Law Coverage

When working correctly, you should see:

### 📊 Wisconsin (WI) - 80 Laws Total

- **Tenant Rights**: 15 laws
- **Traffic Laws**: 18 laws
- **Employment**: 19 laws
- **Taxes**: 13 laws
- **Consumer Protection**: 15 laws

### Sample Wisconsin Laws

**Tenant Rights:**
- Security Deposit: No statutory limit
- Rent Increase Notice: 28 days
- Eviction Notice: 5 days

**Traffic:**
- Speed Limit (Interstate): 70 mph
- Texting While Driving: Banned ($20-$400 fine)
- DUI Limit: 0.08% (0.00% under 21)

**Employment:**
- Minimum Wage: $7.25/hour
- Overtime: 1.5x after 40 hours/week
- Right to Work: Yes

**Taxes:**
- Income Tax: 3.5% - 7.65%
- Sales Tax: 5%
- Property Tax: ~1.73%

---

## Summary

The location feature should work automatically, but if it doesn't:

1. ✅ Manually set location in Simulator
2. ✅ Grant "Always" permission in Settings
3. ✅ Restart the app
4. ✅ Use "Refresh Location" button if needed
5. ✅ Or use Search tab to browse Wisconsin laws manually

All 80 Wisconsin laws are in the app and ready to view! 🎉