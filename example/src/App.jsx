import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  View,
  Alert,
  PermissionsAndroid,
  Platform,
  Button,
  Text,
} from 'react-native';
import { NitroOpenMapView } from 'react-native-nitro-open-map';

export default function App() {
  const [lat] = useState(28.6139);
  const [lng] = useState(77.209);
  const [zoom] = useState(15);
  const [bearing] = useState(0);
  const [tilt] = useState(45);

  const [fitBoundsData, setFitBoundsData] = useState(undefined);
  const [isMapReady, setIsMapReady] = useState(false);

  const [markersList] = useState([
    {
      id: 'marker_1',
      latitude: 28.6139,
      longitude: 77.209,
      title: 'Location 1',
      snippet: 'Draggable Marker',
      iconImage: 'https://cdn-icons-png.flaticon.com/512/741/741407.png',
      rotation: 0,
      draggable: true,
    },
    {
      id: 'marker_2',
      latitude: 28.62,
      longitude: 77.21,
      title: 'Location 2',
      snippet: 'Second Marker',
      iconImage: 'https://cdn-icons-png.flaticon.com/512/555/555526.png',
      rotation: 90,
      draggable: false,
    },
  ]);

  useEffect(() => {
    async function requestLocationPermission() {
      if (Platform.OS === 'android') {
        await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
        );
      }
    }
    requestLocationPermission();

    const timer = setTimeout(() => {
      if (!isMapReady) {
        setIsMapReady(true);
      }
    }, 1500);

    return () => {
      clearTimeout(timer);
    };
  }, [isMapReady]);

  const handleFitBounds = () => {
    if (!isMapReady) return;
    setFitBoundsData([
      { latitude: 28.6139, longitude: 77.209 },
      { latitude: 28.62, longitude: 77.21 },
    ]);
    Alert.alert('Fit Bounds', 'Map bounds adjusted to markers!');
  };

  return (
    <View style={styles.container}>
      <NitroOpenMapView
        color="#6200ff"
        latitude={lat}
        longitude={lng}
        zoom={zoom}
        bearing={bearing}
        tilt={tilt}
        showUserLocation={true}
        fitBoundsCoords={fitBoundsData}
        onMapReady={() => setIsMapReady(true)}
        markers={markersList}
        polylines={[
          {
            id: 'route_1',
            coordinates: [
              { latitude: 28.6139, longitude: 77.209 },
              { latitude: 28.62, longitude: 77.215 },
              { latitude: 28.625, longitude: 77.21 },
            ],
            color: '#0e7305',
            width: 8,
          },
        ]}
        polygons={[
          {
            id: 'zone_1',
            coordinates: [
              { latitude: 28.61, longitude: 77.2 },
              { latitude: 28.615, longitude: 77.2 },
              { latitude: 28.615, longitude: 77.205 },
              { latitude: 28.61, longitude: 77.205 },
            ],
            fillColor: 'rgba(255, 0, 0, 0.3)',
            strokeColor: '#5100ff',
          },
        ]}
        style={styles.map}
      />

      <View style={styles.countBadge}>
        <Text style={styles.countText}>
          Total Markers: {markersList.length}
        </Text>
      </View>

      {!isMapReady && (
        <View style={styles.loadingBanner}>
          <Text style={styles.loadingText}>Map load ho raha hai...</Text>
        </View>
      )}

      <View style={styles.buttonContainer}>
        <View style={styles.buttonWrapper}>
          <Button
            title="Fit Bounds"
            onPress={handleFitBounds}
            disabled={!isMapReady}
          />
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  map: { flex: 1 },
  countBadge: {
    position: 'absolute',
    top: 50,
    left: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 15,
    elevation: 5,
  },
  countText: { color: '#ffffff', fontSize: 14, fontWeight: 'bold' },
  loadingBanner: {
    position: 'absolute',
    top: 100,
    alignSelf: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 16,
  },
  loadingText: { color: '#ffffff', fontSize: 14 },
  buttonContainer: {
    position: 'absolute',
    bottom: 30,
    alignSelf: 'center',
    flexDirection: 'row',
    justifyContent: 'center',
  },
  buttonWrapper: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    overflow: 'hidden',
    elevation: 5,
  },
});
