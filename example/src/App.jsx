import { View, StyleSheet } from 'react-native';
import { NitroOpenMapView } from 'react-native-nitro-open-map';

export default function App() {
  return (
    <View style={styles.container}>
      <NitroOpenMapView style={styles.map} color="#32a852" />
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
