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
  vehicleMarker?: Marker;
  fitBoundsCoords?: LatLng[];
  polylines?: Polyline[];
  polygons?: Polygon[];

  onMarkerPress?: (markerId: string) => void;
  onMarkerDragEnd?: (
    markerId: string,
    latitude: number,
    longitude: number
  ) => void;
}

export interface NitroOpenMapMethods extends HybridViewMethods {
  animateCamera(
    latitude: number,
    longitude: number,
    zoom?: number,
    durationMs?: number
  ): void;
  fitBounds(coordinates: LatLng[], padding?: number): void;
  // Offline Map Download & Cache Method
  downloadOfflineRegion(
    swLat: number,
    swLng: number,
    neLat: number,
    neLng: number,
    minZoom: number,
    maxZoom: number,
    regionName: string
  ): void;
}

export type NitroOpenMap = HybridView<NitroOpenMapProps, NitroOpenMapMethods>;
