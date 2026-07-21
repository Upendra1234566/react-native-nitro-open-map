import React from 'react';
import { StyleSheet, View } from 'react-native';

import { NitroOpenMapView } from 'react-native-nitro-open-map';

export default function App() {
  return (
    <View style={styles.container}>
      <NitroOpenMapView
        color="#FF0000"
        latitude={28.6139}
        longitude={77.209}
        zoom={12}
        markers={[{ latitude: 28.6139, longitude: 77.209, title: 'Delhi' }]}
        style={{ flex: 1 }}
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
