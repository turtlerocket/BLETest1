# Simple Spin Mobile App

## Overview

**Simple Spin** is a mobile app designed to connect to Bluetooth-enabled exercise bikes and provide a simple yet effective exercise dashboard. Tested on the Echelon 4s bike, it displays essential metrics like cadence, resistance, power, and distance, helping users optimize their workout sessions.

### Key Features

1. **Simple Dashboard**: Displays standard exercise bike metrics, including:
   - Cadence (RPM)
   - Resistance
   - Power (Watts)
   - Distance (km or miles)

2. **Bluetooth Connectivity**: Seamlessly connects to Bluetooth-enabled exercise bikes for real-time data.

3. **DEMO Mode**: Enables running the mobile app without an exercise bike to simulate what the app looks like when connected.

4. **DEBUG Mode**: Enables running the mobile app without a valid license and with no expiration.

5. **SANDBOX Mode**: Tests subscription functionality using the App Store sandbox environment.

## Build Settings

The app contains several build settings for evaluation purposes:

1. **DEMO**: 
   - This mode allows you to simulate bike metrics without connecting to an actual exercise bike.  There is no trial period or subscription required.
   - It is useful for testing the dashboard UI and user experience.  

2. **DEBUG**: 
   - This mode allows the app to run without a valid license and has no expiration period. 
   - This requires a bluetooth enabled bike (currently tested on an Echelon 4s spin bike)
   - It is designed for development and testing purposes only.  

3. **SANDBOX**:
   - Allows testing of subscriptions within the App Store sandbox environment using test Apple IDs.  This includes short subscription period. Trial period for mobile app expires in 5 minutes (Release production expires in 7 days).  Subscription expires 15 minutes in Keychain (we reduce server checks for expired subscription by going to Keychain first; note that production release is 30 days for subscription)
   - Requires a functioning bluetooth enabled bike (currently tested on an Echelon 4s bike)
   - To test Trial expiration (5 minutes for SANDBOX), create a new test users.  Once expired, the user must subscribe to a subscription.  Otherwise, the user has no access.
4. **Simple Spin**
    - Product release of software which requires a functioning bluetooth enabled bike (currently tested on an Echelon 4s bike)
    - This is the Release version of the mobile app build with Trial period set to 7 days and Subscription expires in 30 days both in Keychain and Storekit.
   
### Instructions to Access Build Settings

1. Open the project in Xcode.
2. In the "Scheme" dropdown menu, choose the appropriate configuration:
   - **DEMO**: Select the "DEMO" scheme to activate the simulation mode.  No subscription required.
   - **DEBUG**: Select the "DEBUG" scheme to bypass license verification.  Requires bluetooth bike.
   - **SANDBOX**: Select the "SANDBOX" scheme to test subscriptions in the App Store sandbox environment. Requires bluetooth bike.
   - **Simple Spin**: Select the "Simple Spin" scheme to build production RELEASE with 7 day trial period, monthly subscriptions, and full bike connections.  Requires bluetooth bike.

### Testing Guidelines

1. **Simulated Testing (DEMO Mode)**:
   - Verify that the dashboard UI displays appropriate exercise metrics.
   - Check that the user can interact with all dashboard elements smoothly.
   - No exercise bike required

2. **Actual Testing (RELEASE Mode)**:
   - Connect the mobile app to the Echelon 4s or any compatible Bluetooth-enabled exercise bike.
   - Ensure accurate display of cadence, resistance, power, and distance.

3. **License Verification (DEBUG Mode)**:
   - Verify that the app bypasses license verification and operates without expiration.

4. **Subscription Testing (SANDBOX Mode)**:
   - Use test Apple IDs to verify subscription purchase, renewal, and cancellation in the App Store sandbox environment.

## Conclusion

Simple Spin simplifies your workout sessions by providing a reliable and easy-to-understand dashboard, whether you’re using it with an actual exercise bike or simply exploring its features in simulation mode.

**Contact Information**  
For support or additional information, contact us at [contact@simplespinapp.com].


Sandbox Test Users
benjamindai+5@gmail.com - Potato123!
