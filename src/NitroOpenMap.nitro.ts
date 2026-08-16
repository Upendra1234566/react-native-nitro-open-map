// // import type {
// //   HybridView,
// //   HybridViewMethods,
// //   HybridViewProps,
// // } from 'react-native-nitro-modules';

// // export interface Marker {
// //   id?: string;
// //   latitude: number;
// //   longitude: number;
// //   title?: string;
// //   snippet?: string;
// //   description?: string;
// //   rating?: string;
// //   eta?: string;
// //   color?: string;
// //   iconImage?: string;
// //   iconWidth?: number;
// //   iconHeight?: number;
// //   rotation?: number;
// //   anchorX?: number;
// //   anchorY?: number;
// //   alpha?: number;
// //   draggable?: boolean;
// // }

// // export interface LatLng {
// //   latitude: number;
// //   longitude: number;
// // }

// // export interface Polyline {
// //   id: string;
// //   coordinates: LatLng[];
// //   color?: string;
// //   width?: number;
// // }

// // export interface Polygon {
// //   id: string;
// //   coordinates: LatLng[];
// //   fillColor?: string;
// //   strokeColor?: string;
// // }

// // export interface RouteInfo {
// //   distanceKm: number;
// //   etaMinutes: number;
// // }

// // export interface NitroOpenMapProps extends HybridViewProps {
// //   color: string;
// //   latitude?: number;
// //   longitude?: number;
// //   zoom?: number;
// //   bearing?: number;
// //   tilt?: number;
// //   mapStyle?: string;
// //   markers?: Marker[];
// //   showUserLocation?: boolean;
// //   vehicleMarker?: Marker;
// //   fitBoundsCoords?: LatLng[];
// //   polylines?: Polyline[];
// //   polygons?: Polygon[];

// //   onMarkerPress?: (markerId: string) => void;
// //   onMarkerDragEnd?: (
// //     markerId: string,
// //     latitude: number,
// //     longitude: number
// //   ) => void;

// //   // 👇 NAYA — map fully load hone par fire hoga
// //   onMapReady?: () => void;
// // }

// // export interface NitroOpenMapMethods extends HybridViewMethods {
// //   animateCamera(
// //     latitude: number,
// //     longitude: number,
// //     zoom?: number,
// //     durationMs?: number
// //   ): void;

// //   fitBounds(coordinates: LatLng[], padding?: number): void;
// //   downloadOfflineRegion(
// //     swLat: number,
// //     swLng: number,
// //     neLat: number,
// //     neLng: number,
// //     minZoom: number,
// //     maxZoom: number,
// //     regionName: string
// //   ): void;

// //   fetchAndDrawRoute(
// //     originLat: number,
// //     originLng: number,
// //     destLat: number,
// //     destLng: number
// //   ): Promise<RouteInfo>;

// //   // 👇 NAYA — JS se manually bhi check kar sakte ho (fallback ke liye useful)
// //   isMapReady(): Promise<boolean>;
// // }

// // export type NitroOpenMap = HybridView<NitroOpenMapProps, NitroOpenMapMethods>;

// import type {
//   HybridView,
//   HybridViewMethods,
//   HybridViewProps,
// } from 'react-native-nitro-modules';

// export interface Marker {
//   id?: string;
//   latitude: number;
//   longitude: number;
//   title?: string;
//   snippet?: string;
//   description?: string;
//   rating?: string;
//   eta?: string;
//   color?: string;
//   iconImage?: string;
//   iconWidth?: number;
//   iconHeight?: number;
//   rotation?: number;
//   anchorX?: number;
//   anchorY?: number;
//   alpha?: number;
//   draggable?: boolean;
// }

// export interface LatLng {
//   latitude: number;
//   longitude: number;
// }

// export interface Polyline {
//   id: string;
//   coordinates: LatLng[];
//   color?: string;
//   width?: number;
// }

// export interface Polygon {
//   id: string;
//   coordinates: LatLng[];
//   fillColor?: string;
//   strokeColor?: string;
// }

// export interface RouteInfo {
//   distanceKm: number;
//   etaMinutes: number;
// }

// // Naya interface route request ke liye
// export interface RouteRequest {
//   originLat: number;
//   originLng: number;
//   destLat: number;
//   destLng: number;
//   requestId: string;
// }

// export interface NitroOpenMapProps extends HybridViewProps {
//   color: string;
//   latitude?: number;
//   longitude?: number;
//   zoom?: number;
//   bearing?: number;
//   tilt?: number;
//   mapStyle?: string;
//   markers?: Marker[];
//   showUserLocation?: boolean;
//   vehicleMarker?: Marker;
//   fitBoundsCoords?: LatLng[];
//   polylines?: Polyline[];
//   polygons?: Polygon[];
//   routeRequest?: RouteRequest; // 👈 Naya prop jo route trigger karega

//   onMarkerPress?: (markerId: string) => void;
//   onMarkerDragEnd?: (
//     markerId: string,
//     latitude: number,
//     longitude: number
//   ) => void;
//   onMapReady?: () => void;
// }

// export interface NitroOpenMapMethods extends HybridViewMethods {
//   animateCamera(
//     latitude: number,
//     longitude: number,
//     zoom?: number,
//     durationMs?: number
//   ): void;

//   fitBounds(coordinates: LatLng[], padding?: number): void;
//   downloadOfflineRegion(
//     swLat: number,
//     swLng: number,
//     neLat: number,
//     neLng: number,
//     minZoom: number,
//     maxZoom: number,
//     regionName: string
//   ): void;

//   isMapReady(): Promise<boolean>;
// }

// export type NitroOpenMap = HybridView<NitroOpenMapProps, NitroOpenMapMethods>;
import type {
  HybridView,
  HybridViewMethods,
  HybridViewProps,
} from 'react-native-nitro-modules';

export interface Marker {
  id?: string;
  latitude: number;
  longitude: number;
  title?: string;
  snippet?: string;
  description?: string;
  rating?: string;
  eta?: string;
  color?: string;
  iconImage?: string;
  iconWidth?: number;
  iconHeight?: number;
  rotation?: number;
  anchorX?: number;
  anchorY?: number;
  alpha?: number;
  draggable?: boolean;
}

export interface LatLng {
  latitude: number;
  longitude: number;
}

export interface Polyline {
  id: string;
  coordinates: LatLng[];
  color?: string;
  width?: number;
}

export interface Polygon {
  id: string;
  coordinates: LatLng[];
  fillColor?: string;
  strokeColor?: string;
}

export interface NitroOpenMapProps extends HybridViewProps {
  color: string;
  latitude?: number;
  longitude?: number;
  zoom?: number;
  bearing?: number;
  tilt?: number;
  mapStyle?: string;
  markers?: Marker[];
  showUserLocation?: boolean;
  fitBoundsCoords?: LatLng[];
  polylines?: Polyline[];
  polygons?: Polygon[];

  onMarkerPress?: (markerId: string) => void;
  onMarkerDragEnd?: (
    markerId: string,
    latitude: number,
    longitude: number
  ) => void;
  onMapReady?: () => void;
}

export interface NitroOpenMapMethods extends HybridViewMethods {
  animateCamera(
    latitude: number,
    longitude: number,
    zoom?: number,
    durationMs?: number
  ): void;

  fitBounds(coordinates: LatLng[], padding?: number): void;
  isMapReady(): Promise<boolean>;
}

export type NitroOpenMap = HybridView<NitroOpenMapProps, NitroOpenMapMethods>;
