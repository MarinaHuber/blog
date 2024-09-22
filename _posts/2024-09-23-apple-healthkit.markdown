---
layout: epic
title: "Breaking the magic of Apple HealthKit API"
subtitle: What we learned while trying to visualize HK data
date: 2024-09-22
categories: [iOS17, HealthKit, Swift]
author: marina
---

Things I want to accomplish: ✅
1. Show HealthKit workout route on the map
2. Visualize Heart rate and Speed/Pace
3. All this to interoperate with UIKit and SwiftUI

One of the most exciting breakthroughs in modern tech medicine is getting your physical data, biometric data into the EMR (electronic medical record) and into your doctors hands. It first arrived on the mobile market with HealthKit.
HealthKit was introduced by Apple in iOS 8 (mid 2014), a framework that enables developers to interact with health and fitness data on iOS devices. It acts as a centralized repository, collecting data from various sources such as the iPhone’s built-in sensors, third-party devices, and user input. This wealth of information includes but is not limited to steps taken, heart rate, sleep patterns, nutrition, and more. The user has granular access control and it’s all opt-in. Data storage of it doesn't need to be HIPAA compliant and it is the consumer's responsibility to keep their data secure.

<figure class="illustration">
  <img
    src="/blog/images/2024-08-24-apple-healthkit/demo.png"
    alt="Image showing effects of overwhelming data visualisation"
  />
  <figcaption>Data visualization (image by Canvas meme generator)</figcaption>
</figure>

### Configure HealthKit to opt-in

To use HealthKit, you must enable the HealthKit capabilities for your app. In Xcode, select the project and add the HealthKit capability. Only select the Clinical Health Records checkbox if your app needs to access the user’s clinical records. App Review may reject apps that enable the Clinical Health Records capability if the app doesn’t actually use the health record data.
To make your code maintainable and clean, let’s create a `HealthKit Manager` class. This simple class is responsible for retrieving and updating data to the HealthKit.
The HealthKit Manager will interact using HKHealthStore feature to interact with the HealthKit. After that we create a function to request User’s authorization to use their Health data for our application. In this step you prepare a set of datatype you read and write(in basic demo only read is needed). This data type is in .gpx format which is an XML file format for storing coordinate data and health records (like heart rate and speed).

For more information, see full configuration list 🔎[Apple docs](https://developer.apple.com/documentation/healthkit/setting_up_healthkit) 

<figure class="illustration">
  <img
    src="/blog/images/2024-08-24-apple-healthkit/HKConfigure.png"
    alt="Image showing effects of overwhelming data visualisation"
  />
  <figcaption>UIKit HealthKitManager setup (image by Canvas meme generator)</figcaption>
</figure>

### Getting into workout route


### Getting into health data

To accomplish visualization of our workout speed, pace and heart rate values we can use native CareKit or external AAInfographics framework.
In demo case, for the first iteration we imported AAInfographics. 
So what do I need to have to visualize my workout route?
I need to parse the values from `import.gpx` file in this case heart rate and speed, for pace I will calculate according to duration and distance **Pace (sec/km)** = time (sec) / distance (km).

```tsx
extension HealthManager {
    
    private func getIdentifierForType(_ type: HealthValueType) -> HKQuantityTypeIdentifier {
        switch type {
        case .heartRate:
            return .heartRate
        case .speed:
            return .walkingSpeed
        }
    }
    
    private func getUnitForType(_ type: HealthValueType) -> HKUnit {
        switch type {
        case .heartRate:
            return HKUnit(from: "count/min")
        case .speed:
            return HKUnit.meter().unitDivided(by: HKUnit.second())
        }
    }
    
}
```

<figure class="illustration">
  <img
    src="/blog/images/2024-08-24-apple-healthkit/meneHealth.png"
    alt="Image showing effects of overwhelming data visualisation"
  />
  <figcaption>Data visualization (image by Canvas meme generator)</figcaption>
</figure>

### Conclusion

TBC

Full demo: [Github](https://github.com/MarinaHuber/HealthKitDemo)
Helpful link for code-gen with [ChatGPT](https://chatgpt.com/g/g-o1UC7Hh1s-apple-healthkit-complete-guide)
<!-- more -->

