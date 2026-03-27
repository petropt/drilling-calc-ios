# Drilling Calc

Native SwiftUI drilling calculator for iOS. 20 offline-capable calculators for drilling engineers.

## Calculators

### Free (10)
- Hydrostatic Pressure
- ECD (Equivalent Circulating Density)
- Formation Pressure Gradient
- Buoyancy Factor
- Pipe Capacity
- Annular Capacity
- Annular Velocity
- Dogleg Severity
- Mud Weight Equivalent
- Bottom Hole Temperature

### Pro (10)
- Kill Mud Weight
- Initial Circulating Pressure (ICP)
- Final Circulating Pressure (FCP)
- MAASP
- Bit Hydraulics (TFA, HSI, dP)
- Casing Burst (Barlow)
- Nozzle TFA
- Cement Volume
- Swab Pressure
- Kick Tolerance

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Build

Open `DrillingCalc/DrillingCalc.xcodeproj` in Xcode and run on a simulator or device.

To run tests:
```bash
cd DrillingCalc
xcodebuild test -project DrillingCalc.xcodeproj -scheme DrillingCalc -destination 'platform=iOS Simulator,name=iPhone 16'
```

## About

Built by [Groundwork Analytics](https://groundworkanalytics.com)
