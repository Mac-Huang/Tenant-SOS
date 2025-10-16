# Testing Location Feature for Wisconsin

## ✅ Changes Made

### 1. **Removed Subscription System**
- Deleted ProUpgradeView and StoreManager
- Removed all payment/subscription UI elements
- All features are now FREE for all users

### 2. **Opened All States to All Users**
- No more Pro restrictions
- Unlimited document generation
- Access to all 50 states' laws

### 3. **Added Wisconsin Law Data**
- Complete Wisconsin tenant rights laws
- Wisconsin traffic laws (including texting ban)
- Wisconsin employment laws ($7.25/hr minimum wage)
- Wisconsin tax rates (3.5% - 7.65% income tax)
- Wisconsin consumer protection laws

## 📍 Testing the Wisconsin Location Feature

### In Simulator:

1. **Launch the App**
   - Open the app in simulator
   - Complete onboarding if needed
   - Grant "Always Allow" location permission

2. **Set Initial Location (if not in Wisconsin)**
   - Debug menu → Location → Custom Location
   - Set to another state first, e.g., Illinois:
     - Latitude: 41.8781
     - Longitude: -89.3985

3. **Simulate Travel to Wisconsin**
   - Press Home button to background the app
   - Debug menu → Location → Custom Location
   - Set to Wisconsin (Madison):
     - **Latitude: 43.0731**
     - **Longitude: -89.4012**

4. **Expected Notification**
   You should receive a notification like:
   ```
   Welcome to Wisconsin!
   ⚠️ Key law differences:
   💰 Minimum wage: $7.25/hour (was $13.00/hour)
   🏠 Notice for rent increase: 28 days
   💸 State income tax: 3.5% - 7.65%

   Tap for complete details
   ```

### Wisconsin Key Cities Coordinates:

- **Madison (Capital)**: 43.0731, -89.4012
- **Milwaukee**: 43.0389, -87.9065
- **Green Bay**: 44.5133, -88.0133
- **Kenosha**: 42.5847, -87.8212
- **Racine**: 42.7261, -87.7829

### Testing State-to-State Comparisons:

**From Illinois to Wisconsin:**
- Key differences:
  - Minimum wage drops from $13/hr to $7.25/hr
  - Income tax changes from 4.95% flat to 3.5%-7.65% progressive
  - Sales tax changes from 6.25% to 5%

**From California to Wisconsin:**
- Critical differences:
  - No rent control (was 5% + inflation cap)
  - Minimum wage: $7.25/hr (was $16/hr)
  - Different tenant notice periods

**From Texas to Wisconsin:**
- Key differences:
  - State income tax applies (Texas has none)
  - Similar minimum wage ($7.25/hr)
  - Different tenant laws

## 🧪 What to Verify

1. **Background Detection Works**
   - App detects state change even when closed
   - Blue location indicator shows app is monitoring

2. **Notification Content**
   - Shows correct state name (Wisconsin)
   - Lists most important law differences
   - Differences are accurate based on previous state

3. **Tap Notification**
   - Opens StateDifferencesView
   - Shows detailed comparison
   - Can filter by category (Tenant, Traffic, Employment, etc.)

4. **No Subscription Prompts**
   - No upgrade buttons
   - No payment screens
   - All features accessible

## 📱 Real Device Testing

If you're actually in Wisconsin:
1. The app should detect your location automatically
2. Shows "Wisconsin" as current state on home screen
3. When you travel to another state, you'll get notifications

## 🐛 Troubleshooting

- **No notification?**
  - Check notification permissions in Settings
  - Ensure "Always Allow" location permission
  - Try moving further (coordinates differ by >100m)

- **Wrong state detected?**
  - GPS accuracy issues
  - Try different coordinates within Wisconsin
  - Check internet connection for geocoding

- **App crashes?**
  - Clear DerivedData
  - Clean build folder
  - Reinstall app

## ✅ Success Criteria

The Wisconsin location feature is working if:
1. ✅ App detects when you enter Wisconsin
2. ✅ Shows notification with key law differences
3. ✅ Displays Wisconsin-specific laws correctly
4. ✅ No subscription/payment prompts appear
5. ✅ All documents can be generated for free