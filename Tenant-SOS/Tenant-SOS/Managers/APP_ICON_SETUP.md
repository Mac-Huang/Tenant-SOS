# App Icon Setup Instructions

To set up the Tenant_SOS_Logo_1024.png as your app icon, follow these steps:

## Method 1: Using Xcode (Recommended)

1. Open your project in Xcode
2. In the Project Navigator, find and open `Assets.xcassets`
3. Look for the `AppIcon` asset (if it doesn't exist, right-click in Assets.xcassets and select "New Image Set", then rename it to "AppIcon")
4. Select the AppIcon asset
5. In the Attributes Inspector (right panel), ensure "iOS" is checked under "Platforms"
6. Drag your `Tenant_SOS_Logo_1024.png` file into the "1024x1024" slot (this is the App Store icon)

## Required Icon Sizes for iOS

You'll need to create multiple sizes of your icon. You can use the 1024x1024 version to generate these:

- **iPhone App Icons:**
  - 180x180 (60pt@3x) - iPhone
  - 120x120 (60pt@2x) - iPhone
  - 87x87 (29pt@3x) - iPhone Settings
  - 58x58 (29pt@2x) - iPhone Settings
  - 80x80 (40pt@2x) - iPhone Spotlight
  - 120x120 (40pt@3x) - iPhone Spotlight

- **iPad App Icons (if supporting iPad):**
  - 152x152 (76pt@2x) - iPad
  - 167x167 (83.5pt@2x) - iPad Pro
  - 80x80 (40pt@2x) - iPad Spotlight
  - 58x58 (29pt@2x) - iPad Settings

## Method 2: Using Asset Catalog File Structure

If you need to set up the asset catalog manually:

1. Create a folder structure like this:
   ```
   Assets.xcassets/
   ├── AppIcon.appiconset/
   │   ├── Contents.json
   │   ├── icon-1024.png (1024x1024)
   │   ├── icon-180.png (180x180)
   │   ├── icon-120.png (120x120)
   │   ├── icon-87.png (87x87)
   │   ├── icon-80.png (80x80)
   │   └── icon-58.png (58x58)
   ```

2. Create a `Contents.json` file with the appropriate references

## Quick Icon Generation Tools

You can use online tools or apps to generate all required sizes from your 1024x1024 icon:
- [App Icon Generator](https://appicon.co/)
- [MakeAppIcon](https://makeappicon.com/)
- [Icon Set Creator](https://apps.apple.com/app/icon-set-creator/id1294179975) (Mac App Store)

## Verification

After adding the icons:
1. Build and run your app
2. Check that the icon appears correctly on the simulator/device home screen
3. Verify the icon appears in the App Store Connect when you upload your build

## Important Notes

- Icons should be PNG format
- Icons should not have transparency (alpha channel)
- Icons should not have rounded corners (iOS adds these automatically)
- Make sure your icon follows Apple's Human Interface Guidelines
- The 1024x1024 icon is required for App Store submission

## Current Project Setup

Your project should have:
- The icon file: `Tenant_SOS_Logo_1024.png` in the `Tenant-SOS/AppStoreMetadata` folder
- An `Assets.xcassets` folder in your main project
- An `AppIcon` image set within the asset catalog

If any of these are missing, create them following the steps above.