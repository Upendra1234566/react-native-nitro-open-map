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
  const [routeInfo, setRouteInfo] = useState(null);
  const [routeReq, setRouteReq] = useState(undefined);
  const [isMapReady, setIsMapReady] = useState(false);

  const [vehicle, setVehicle] = useState({
    id: 'live_vehicle',
    latitude: 28.6139,
    longitude: 77.209,
    title: 'Live Rider',
    iconImage: 'https://cdn-icons-png.flaticon.com/512/741/741407.png',
    rotation: 45,
  });

  const [markersList] = useState([
    {
      id: 'marker_1',
      latitude: 28.6139,
      longitude: 77.209,
      title: 'Car 1',
      snippet: 'Draggable Car Marker',
      rating: '4.8 ⭐',
      eta: '10 mins',
      iconImage: 'https://cdn-icons-png.flaticon.com/512/741/741407.png',
      rotation: 0,
      draggable: true,
    },
    {
      id: 'marker_2',
      latitude: 28.62,
      longitude: 77.21,
      title: 'Car 2',
      snippet: 'Second Car Marker',
      rating: '4.5 ⭐',
      eta: '15 mins',
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

    const interval = setInterval(() => {
      setVehicle((prev) => {
        const newLat = prev.latitude + 0.0005;
        const newLng = prev.longitude + 0.0005;
        const randomRotation = (prev.rotation + 15) % 360;
        return {
          ...prev,
          latitude: newLat,
          longitude: newLng,
          rotation: randomRotation,
        };
      });
    }, 3000);

    return () => {
      clearInterval(interval);
      clearTimeout(timer);
    };
  }, [isMapReady]);

  const handleFitBounds = () => {
    if (!isMapReady) return;
    setFitBoundsData([
      { latitude: 28.6139, longitude: 77.209 },
      { latitude: 28.62, longitude: 77.21 },
      { latitude: vehicle.latitude, longitude: vehicle.longitude },
    ]);
  };

  const handleFetchRoute = () => {
    if (!isMapReady) return;

    setRouteReq({
      originLat: vehicle.latitude,
      originLng: vehicle.longitude,
      destLat: 28.62,
      destLng: 77.21,
      requestId: Date.now().toString(),
    });

    setRouteInfo({ distance: '2.50', eta: '10' });
    Alert.alert('Success', 'Route fetch request sent to native map!');
  };

  const handleOfflineMapDownload = () => {
    if (!isMapReady) return;
    Alert.alert('Offline Map', 'Offline map download option triggered!');
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
        vehicleMarker={vehicle}
        fitBoundsCoords={fitBoundsData}
        routeRequest={routeReq}
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
          Total Cars on Map: {markersList.length}
        </Text>
      </View>

      {routeInfo && (
        <View style={styles.routeInfoCard}>
          <Text style={styles.routeInfoText}>
            Distance: {routeInfo.distance} km
          </Text>
          <Text style={styles.routeInfoText}>ETA: {routeInfo.eta} mins</Text>
        </View>
      )}

      {!isMapReady && (
        <View style={styles.loadingBanner}>
          <Text style={styles.loadingText}>Map load ho raha hai...</Text>
        </View>
      )}

      <View style={styles.buttonContainer}>
        <View style={styles.buttonWrapper}>
          <Button
            title="Get Route"
            color="#d84315"
            onPress={handleFetchRoute}
            disabled={!isMapReady}
          />
        </View>
        <View style={styles.buttonWrapper}>
          <Button
            title="Fit Bounds"
            onPress={handleFitBounds}
            disabled={!isMapReady}
          />
        </View>
        <View style={styles.buttonWrapper}>
          <Button
            title="Offline Map"
            color="#2e7d32"
            onPress={handleOfflineMapDownload}
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
  routeInfoCard: {
    position: 'absolute',
    top: 50,
    alignSelf: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 20,
    elevation: 5,
  },
  routeInfoText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
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
    flexWrap: 'wrap',
    gap: 10,
    justifyContent: 'center',
  },
  buttonWrapper: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    overflow: 'hidden',
    elevation: 5,
  },
});
