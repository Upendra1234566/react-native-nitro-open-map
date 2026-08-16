# react-native-nitro-open-map

High-performance React Native Map component built with **Nitro Modules** and **MapLibre Native**.
`react-native-nitro-open-map` provides a fast native map view for React Native applications with zero-bridge overhead using Nitro Modules. Built for developers who need a lightweight, high-performance alternative to existing native map solutions.

---

## Features

- Native Android and iOS rendering via MapLibre
- Built with React Native Nitro Modules (zero bridge overhead)
- High performance native map view
- Full TypeScript support
- Standard markers, custom icons, and drag support
- Polyline and polygon overlay drawing
- User location tracking integration
- Camera and zoom controls

## 📋 Table of Contents

- [Installation](#installation)
- [Requirements](#requirements)
- [Android Setup](#android-setup)
- [iOS Setup](#ios-setup)
- [Usage](#usage)
- [Props / API](#props--api)
- [Contributing](#contributing)
- [License](#license)

---

## Installation

```bash
npm install react-native-nitro-open-map react-native-nitro-modules
```

or

```bash
yarn add react-native-nitro-open-map react-native-nitro-modules
```

## Requirements

- React Native >= 0.76
- Node >= 18
- React Native New Architecture enabled

---

## Android Setup

### 1. Permissions

Add the following permissions inside `android/app/src/main/AndroidManifest.xml`, **outside** the `<application>` tag:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 2. MapLibre Renderer Meta-Data

Add the renderer configuration **inside** the `<application>` tag in the same file:

```xml
<meta-data
    android:name="org.maplibre.android.renderer"
    android:value="OPENGL" />
```

---

## iOS Setup

### 1. Permissions

Add the following location permission keys inside `ios/YourAppName/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show you on the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location for tracking purposes.</string>
```

### 2. Install Pods

Navigate to your iOS directory and run `pod install` to link the native dependencies:

```bash
cd ios && pod install
```

---

## Usage

```jsx
import React from 'react';
import { View, StyleSheet } from 'react-native';
import { NitroOpenMapView } from 'react-native-nitro-open-map';

export default function App() {
  return (
    <View style={styles.container}>
      <NitroOpenMapView
        color="#dd8213cc"
        latitude={28.6139}
        longitude={77.209}
        zoom={15}
        showUserLocation={true}
        style={styles.map}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
});
```

## Props / API

| Prop               | Type        | Default | Description                                 |
| ------------------ | ----------- | ------- | ------------------------------------------- |
| `latitude`         | `number`    | —       | Initial latitude of the map center          |
| `longitude`        | `number`    | —       | Initial longitude of the map center         |
| `zoom`             | `number`    | `14`    | Initial zoom level                          |
| `color`            | `string`    | —       | Accent color used for markers/overlays      |
| `showUserLocation` | `boolean`   | `false` | Show the user's current location on the map |
| `style`            | `ViewStyle` | —       | Standard React Native style prop            |

---

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check the [issues page](https://github.com/) if you want to contribute.

## License

MIT © [Upendra Singh]
