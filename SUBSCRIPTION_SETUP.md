# Subscription Setup for App Store Connect

## Product IDs in Code
The app uses these product IDs:
- `com.tenantsos.pro.monthly` - Monthly subscription
- `com.tenantsos.pro.yearly` - Yearly subscription

## App Store Connect Configuration Required

### 1. Monthly Subscription
- **Product ID**: `com.tenantsos.pro.monthly`
- **Price**: $0.99 USD
- **Duration**: 1 Month
- **Auto-renewable**: Yes
- **Display Name**: "Pro Monthly"
- **Description**: "Unlimited documents and all states access"

### 2. Yearly Subscription (Optional - for better value)
- **Product ID**: `com.tenantsos.pro.yearly`
- **Price**: $9.99 USD (save ~17%)
- **Duration**: 1 Year
- **Auto-renewable**: Yes
- **Display Name**: "Pro Yearly"
- **Description**: "Best value! Unlimited documents and all states access"

## Steps to Configure in App Store Connect

1. Go to App Store Connect > Your App > Monetization > Subscriptions
2. Create a new subscription group called "Pro Access"
3. Add the monthly subscription:
   - Reference Name: "Pro Monthly"
   - Product ID: `com.tenantsos.pro.monthly`
   - Set price to Tier 1 ($0.99)
4. Add the yearly subscription (optional):
   - Reference Name: "Pro Yearly"
   - Product ID: `com.tenantsos.pro.yearly`
   - Set price to Tier 10 ($9.99)
5. Add localized descriptions for each subscription
6. Set up the subscription group localization
7. Submit for review with your next app update

## Testing
- Use sandbox testers to verify purchases work correctly
- The actual prices shown in the app come from StoreKit/App Store Connect
- The hardcoded "$0.99/mo" in ProfileView is just a placeholder

## Important Notes
- The actual subscription prices are controlled by App Store Connect, not the code
- The app uses StoreKit 2 to fetch and display real prices
- Make sure to test with sandbox accounts before submission