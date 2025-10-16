# App Store Review Response - Background Location Feature

## Response to Guideline 2.5.4 - Performance - Software Requirements

Thank you for reviewing Tenant SOS. We'd like to clarify the background location feature, which is a **core functionality** of our app.

## Background Location Use Case

Tenant SOS is designed to **automatically notify travelers about critical legal differences when they cross state borders**, even when the app is not actively in use. This is essential for:

1. **Interstate Travelers**: Automatically alerting users when they enter states with different tenant laws, traffic regulations, or employment rules
2. **Legal Compliance**: Ensuring users are immediately aware of law changes that could affect them (e.g., different rental deposit limits, eviction notice periods)
3. **Safety**: Notifying about critical differences like hands-free driving laws or rental rights

## How to Test the Background Location Feature

### Demo Instructions:

1. **Initial Setup** (in California or any supported state):
   - Launch the app
   - Complete onboarding
   - When prompted, allow "Always Allow" location permission
   - Grant notification permissions
   - Note your current state shown on the home screen

2. **Testing Background State Detection**:
   - Press the Home button to put the app in background
   - **For Simulator Testing**:
      - In Simulator, go to Features > Location > Custom Location
      - Change location to Texas: Latitude: 31.0000, Longitude: -100.0000
      - Wait 10-15 seconds
      - You'll receive a notification: "Welcome to Texas! Tap to see important laws..."

   - **For Real Device Testing**:
      - Drive/travel across a state border
      - Or use Xcode's Location Simulation to simulate movement

3. **Verify Background Functionality**:
   - The notification appears WITHOUT opening the app
   - The blue location indicator shows the app is monitoring location
   - Tap notification to see state-specific law differences

## Why Background Location is Essential

Unlike apps that only need location when in use, Tenant SOS provides **proactive legal awareness**:

- **Automatic Detection**: Users don't need to remember to check the app when traveling
- **Immediate Alerts**: Critical law differences are pushed immediately upon state entry
- **Legal Protection**: Users are informed of their rights/obligations before they might unknowingly violate local laws

## Technical Implementation

We use:
- **Significant Location Changes API**: Battery-efficient monitoring
- **Geofencing**: Monitor state boundary regions
- **Local Notifications**: Immediate alerts when crossing borders
- Only tracks when users explicitly grant "Always Allow" permission

## Privacy & Battery Considerations

- Location data is processed locally, never uploaded to servers
- Uses iOS's power-efficient location APIs
- Users can disable at any time in Settings
- Clear explanation provided during onboarding about why we need this permission

## Supported States for Testing

Currently monitoring these states with geofences:
- California (CA): 36.7783, -119.4179
- Texas (TX): 31.0000, -100.0000
- New York (NY): 43.0000, -75.0000
- Florida (FL): 27.6648, -81.5158
- Illinois (IL): 40.6331, -89.3985

## Video Demo Available

We can provide a video demonstration showing:
1. App in background (Home screen visible)
2. Location change simulation
3. Notification appearing automatically
4. Opening notification to see state-specific laws

This feature is fundamental to our app's value proposition - providing automatic legal awareness for travelers without requiring them to actively check the app.

Thank you for your consideration. We're happy to provide any additional information or demonstration needed.

---

## Sample Test Locations for Simulator

### From California to Nevada:
- Start: San Francisco (37.7749, -122.4194)
- End: Reno (39.5296, -119.8138)

### From New York to New Jersey:
- Start: New York City (40.7128, -74.0060)
- End: Newark (40.7357, -74.1724)

### From Texas to Oklahoma:
- Start: Dallas (32.7767, -96.7970)
- End: Oklahoma City (35.4676, -97.5164)