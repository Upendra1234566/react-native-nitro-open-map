// import React, { useState, useEffect, useRef } from 'react';
// import { StyleSheet, View, Alert, PermissionsAndroid, Platform, Button } from 'react-native';
// import { NitroOpenMapView } from 'react-native-nitro-open-map';

// export default function App() {
//   const mapRef = useRef(null); // Map reference for calling native methods

//   const [lat, setLat] = useState(28.6139);
//   const [lng, setLng] = useState(77.2090);
//   const [zoom, setZoom] = useState(15);
//   const [bearing, setBearing] = useState(0);
//   const [tilt, setTilt] = useState(45);

//   const [fitBoundsData, setFitBoundsData] = useState(undefined);

//   // YAHAN CHANGE KIYA HAI: S3 wali image ka link daal diya hai
//   const [vehicle, setVehicle] = useState({
//     id: 'live_vehicle',
//     latitude: 28.6139,
//     longitude: 77.2090,
//     title: 'Live Rider',
//     iconImage: 'https://hbb-food-media.s3.ap-south-1.amazonaws.com/uploads/455f2fa0-5407-4a43-a595-a9d2c7211aeb.jpg',
//     rotation: 45, // Initial rotation angle
//   });

//   const [markersList, setMarkersList] = useState([
//     { 
//       id: 'marker_s3',
//       latitude: 28.6139, 
//       longitude: 77.2090, 
//       title: 'S3 Image Marker (Draggable)',
//       snippet: 'Long press and drag me!',
//       rating: '4.8 ⭐',
//       eta: '10 mins',
//       iconImage: 'https://hbb-food-media.s3.ap-south-1.amazonaws.com/uploads/455f2fa0-5407-4a43-a595-a9d2c7211aeb.jpg',
//       rotation: 0,
//       draggable: true
//     },
//     {
//       id: 'marker_default',
//       latitude: 28.6200,
//       longitude: 77.2100,
//       title: 'Default Icon Spot',
//       snippet: 'Static Marker',
//       rating: '4.5 ⭐',
//       eta: '15 mins',
//       iconImage: 'default_marker_icon',
//       rotation: 90, // Rotated marker example
//       draggable: false
//     }
//   ]);

//   useEffect(() => {
//     async function requestLocationPermission() {
//       if (Platform.OS === 'android') {
//         await PermissionsAndroid.request(
//           PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
//         );
//       }
//     }
//     requestLocationPermission();

//     // Live vehicle movement simulation with dynamic rotation
//     const interval = setInterval(() => {
//       setVehicle((prev) => {
//         const newLat = prev.latitude + 0.0005;
//         const newLng = prev.longitude + 0.0005;
        
//         // Simple angle calculation simulation for vehicle heading direction
//         const randomRotation = (prev.rotation + 15) % 360;

//         return {
//           ...prev,
//           latitude: newLat,
//           longitude: newLng,
//           rotation: randomRotation,
//         };
//       });
//     }, 3000);

//     return () => clearInterval(interval);
//   }, []);

//   const handleFitBounds = () => {
//     setFitBoundsData([
//       { latitude: 28.6139, longitude: 77.2090 }, // S3 marker
//       { latitude: 28.6200, longitude: 77.2100 }, // Default marker
//       { latitude: vehicle.latitude, longitude: vehicle.longitude } // Current vehicle position
//     ]);
//   };

//   // Offline Region Download Handler
//   const handleDownloadOfflineMap = () => {
//     if (mapRef.current && mapRef.current.downloadOfflineRegion) {
//       mapRef.current.downloadOfflineRegion(
//         28.5, 77.1, // SW Lat, Lng
//         28.7, 77.3, // NE Lat, Lng
//         10, 16,     // Min & Max Zoom
//         "Delhi_Offline_Region"
//       );
//       Alert.alert("Offline Map", "Downloading and caching map tiles for offline usage...");
//     } else {
//       Alert.alert("Error", "Map reference not ready yet!");
//     }
//   };

//   return (
//     <View style={styles.container}>
//       <NitroOpenMapView 
//         ref={mapRef}
//         color="#6200ff"
//         latitude={lat}
//         longitude={lng}
//         zoom={zoom}
//         bearing={bearing}
//         tilt={tilt}
//         showUserLocation={true}
//         vehicleMarker={vehicle}
//         fitBoundsCoords={fitBoundsData}
//         polylines={[
//           {
//             id: 'route_1',
//             coordinates: [
//               { latitude: 28.6139, longitude: 77.2090 },
//               { latitude: 28.6200, longitude: 77.2150 },
//               { latitude: 28.6250, longitude: 77.2100 }
//             ],
//             color: '#0e7305',
//             width: 10
//           }
//         ]}
//         polygons={[
//           {
//             id: 'zone_1',
//             coordinates: [
//               { latitude: 28.6100, longitude: 77.2000 },
//               { latitude: 28.6150, longitude: 77.2000 },
//               { latitude: 28.6150, longitude: 77.2050 },
//               { latitude: 28.6100, longitude: 77.2050 }
//             ],
//             fillColor: 'rgba(255, 0, 0, 0.3)',
//             strokeColor: '#5100ff'
//           }
//         ]}
//         onMarkerPress={(markerId) => {
//           Alert.alert("Marker Clicked!", `You pressed marker ID: ${markerId}`);
//         }}
//         onMarkerDragEnd={(markerId, newLat, newLng) => {
//           Alert.alert("Marker Dragged!", `ID: ${markerId}\nLat: ${newLat}\nLng: ${newLng}`);
//           setMarkersList((prev) =>
//             prev.map((m) => (m.id === markerId ? { ...m, latitude: newLat, longitude: newLng } : m))
//           );
//         }}
//         markers={markersList}
//         style={{ flex: 1 }}
//       />

//       {/* Button Controls Container */}
//       <View style={styles.buttonContainer}>
//         <View style={styles.buttonWrapper}>
//           <Button title="Fit All Markers" onPress={handleFitBounds} />
//         </View>
//         <View style={styles.buttonWrapper}>
//           <Button title="Download Offline Map" color="#2e7d32" onPress={handleDownloadOfflineMap} />
//         </View>
//       </View>
//     </View>
//   );
// }

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//   },
//   buttonContainer: {
//     position: 'absolute',
//     bottom: 40,
//     alignSelf: 'center',
//     flexDirection: 'row',
//     gap: 10,
//   },
//   buttonWrapper: {
//     backgroundColor: '#ffffff',
//     borderRadius: 8,
//     overflow: 'hidden',
//     elevation: 5,
//   },
// }); 

import React, { useState, useEffect, useRef } from 'react';
import {
  StyleSheet,
  View,
  Alert,
  PermissionsAndroid,
  Platform,
  Button,
} from 'react-native';
import { NitroOpenMapView } from 'react-native-nitro-open-map';

export default function App() {
  const mapRef = useRef(null); // Map reference for calling native methods

  // Unused setters removed to fix ESLint warnings
  const [lat] = useState(28.6139);
  const [lng] = useState(77.209);
  const [zoom] = useState(15);
  const [bearing] = useState(0);
  const [tilt] = useState(45);

  const [fitBoundsData, setFitBoundsData] = useState(undefined);

  const [vehicle, setVehicle] = useState({
    id: 'live_vehicle',
    latitude: 28.6139,
    longitude: 77.209,
    title: 'Live Rider',
    iconImage:
      'https://hbb-food-media.s3.ap-south-1.amazonaws.com/uploads/455f2fa0-5407-4a43-a595-a9d2c7211aeb.jpg',
    rotation: 45, // Initial rotation angle
  });

  const [markersList, setMarkersList] = useState([
    {
      id: 'marker_s3',
      latitude: 28.6139,
      longitude: 77.209,
      title: 'S3 Image Marker (Draggable)',
      snippet: 'Long press and drag me!',
      rating: '4.8 ⭐',
      eta: '10 mins',
      iconImage:
        'https://hbb-food-media.s3.ap-south-1.amazonaws.com/uploads/455f2fa0-5407-4a43-a595-a9d2c7211aeb.jpg',
      rotation: 0,
      draggable: true,
    },
    {
      id: 'marker_default',
      latitude: 28.62,
      longitude: 77.21,
      title: 'Default Icon Spot',
      snippet: 'Static Marker',
      rating: '4.5 ⭐',
      eta: '15 mins',
      iconImage: 'default_marker_icon',
      rotation: 90, // Rotated marker example
      draggable: false,
    },
  ]);

  useEffect(() => {
    async function requestLocationPermission() {
      if (Platform.OS === 'android') {
        await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
        );
      }
    }
    requestLocationPermission();

    // Live vehicle movement simulation with dynamic rotation
    const interval = setInterval(() => {
      setVehicle((prev) => {
        const newLat = prev.latitude + 0.0005;
        const newLng = prev.longitude + 0.0005;

        // Simple angle calculation simulation for vehicle heading direction
        const randomRotation = (prev.rotation + 15) % 360;

        return {
          ...prev,
          latitude: newLat,
          longitude: newLng,
          rotation: randomRotation,
        };
      });
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  const handleFitBounds = () => {
    setFitBoundsData([
      { latitude: 28.6139, longitude: 77.209 }, // S3 marker
      { latitude: 28.62, longitude: 77.21 }, // Default marker
      { latitude: vehicle.latitude, longitude: vehicle.longitude }, // Current vehicle position
    ]);
  };

  // Offline Region Download Handler
  const handleDownloadOfflineMap = () => {
    if (mapRef.current && mapRef.current.downloadOfflineRegion) {
      mapRef.current.downloadOfflineRegion(
        28.5,
        77.1, // SW Lat, Lng
        28.7,
        77.3, // NE Lat, Lng
        10,
        16, // Min & Max Zoom
        'Delhi_Offline_Region',
      );
      Alert.alert(
        'Offline Map',
        'Downloading and caching map tiles for offline usage...',
      );
    } else {
      Alert.alert('Error', 'Map reference not ready yet!');
    }
  };

  return (
    <View style={styles.container}>
      <NitroOpenMapView
        ref={mapRef}
        color="#6200ff"
        latitude={lat}
        longitude={lng}
        zoom={zoom}
        bearing={bearing}
        tilt={tilt}
        showUserLocation={true}
        vehicleMarker={vehicle}
        fitBoundsCoords={fitBoundsData}
        polylines={[
          {
            id: 'route_1',
            coordinates: [
              { latitude: 28.6139, longitude: 77.209 },
              { latitude: 28.62, longitude: 77.215 },
              { latitude: 28.625, longitude: 77.21 },
            ],
            color: '#0e7305',
            width: 10,
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
        onMarkerPress={(markerId) => {
          Alert.alert('Marker Clicked!', `You pressed marker ID: ${markerId}`);
        }}
        onMarkerDragEnd={(markerId, newLat, newLng) => {
          Alert.alert(
            'Marker Dragged!',
            `ID: ${markerId}\nLat: ${newLat}\nLng: ${newLng}`,
          );
          setMarkersList((prev) =>
            prev.map((m) =>
              m.id === markerId
                ? { ...m, latitude: newLat, longitude: newLng }
                : m,
            ),
          );
        }}
        markers={markersList}
        style={styles.map}
      />

      {/* Button Controls Container */}
      <View style={styles.buttonContainer}>
        <View style={styles.buttonWrapper}>
          <Button title="Fit All Markers" onPress={handleFitBounds} />
        </View>
        <View style={styles.buttonWrapper}>
          <Button
            title="Download Offline Map"
            color="#2e7d32"
            onPress={handleDownloadOfflineMap}
          />
        </View>
      </View>
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
  buttonContainer: {
    position: 'absolute',
    bottom: 40,
    alignSelf: 'center',
    flexDirection: 'row',
    gap: 10,
  },
  buttonWrapper: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    overflow: 'hidden',
    elevation: 5,
  },
});