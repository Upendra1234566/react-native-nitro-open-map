# react-native-nitro-open-map 🚀

High-performance React Native Map component built with **Nitro Modules** and **MapLibre Native**.

`react-native-nitro-open-map` provides a fast native map view for React Native applications with zero-bridge overhead using Nitro Modules.

Built for developers who need a lightweight and high-performance alternative for native maps.

## ✨ Features

✅ Native Android MapLibre rendering  
✅ Built with React Native Nitro Modules  
✅ Zero bridge overhead  
✅ High performance native map view  
✅ Offline map support through MapLibre ecosystem  
✅ Android support  
✅ TypeScript support  

## 🚧 Coming Soon

The following features are under active development:

- 📍 Latitude / Longitude camera control
- 🔍 Zoom control
- 📌 Marker support
- 🧭 User location tracking integration
- 🚗 Live moving vehicle marker
- 🛣️ Polyline and route drawing
- 🗺️ Custom map styles
- 📍 Multiple markers
- 🧱 Polygon and circle overlays
- 🌍 iOS support

---

# Installation

```bash
npm install react-native-nitro-open-map react-native-nitro-modules
OR 
yarn add react-native-nitro-open-map react-native-nitro-modules

Requirements
React Native >= 0.76
Node >= 18
React Native New Architecture enabled 
`


Usage
``
import React from 'react';
import { View, StyleSheet } from 'react-native';

import { NitroOpenMapView } from 'react-native-nitro-open-map';


export default function App(){

  return (
    <View style={styles.container}>

      <NitroOpenMapView
        style={styles.map}
      />

    </View>
  );
}


const styles = StyleSheet.create({

  container:{
    flex:1,
  },

  map:{
    flex:1,
  }

});
``
License

MIT © Upendra Singh