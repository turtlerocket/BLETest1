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

## Build Settings

The app contains two build settings for evaluation purposes:

1. **DEMO**: 
   - This mode allows you to simulate bike metrics without connecting to an actual exercise bike. 
   - It is useful for testing the dashboard UI and user experience.

2. **DEBUG**: 
   - This mode allows the app to run without a valid license and has no expiration period. 
   - It is designed for development and testing purposes only.

### Instructions to Access Build Settings

1. Open the project in Xcode.
2. In the "Scheme" dropdown menu, choose the appropriate configuration:
   - **DEMO**: Select the "DEMO" scheme to activate the simulation mode.
   - **DEBUG**: Select the "DEBUG" scheme to bypass license verification.

### Testing Guidelines

1. **Simulated Testing (DEMO Mode)**:
   - Verify that the dashboard UI displays appropriate exercise metrics.
   - Check that the user can interact with all dashboard elements smoothly.

2. **Actual Testing (RELEASE Mode)**:
   - Connect the mobile app to the Echelon 4s or any compatible Bluetooth-enabled exercise bike.
   - Ensure accurate display of cadence, resistance, power, and distance.

3. **License Verification (DEBUG Mode)**:
   - Verify that the app bypasses license verification and operates without expiration.

## Conclusion

Simple Spin simplifies your workout sessions by providing a reliable and easy-to-understand dashboard, whether you’re using it with an actual exercise bike or simply exploring its features in simulation mode.

**Contact Information**  
For support or additional information, contact us at [contact@simplespinapp.com].
