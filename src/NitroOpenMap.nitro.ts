import type {
  HybridView,
  HybridViewMethods,
  HybridViewProps,
} from 'react-native-nitro-modules';

export interface Marker {
  latitude: number;
  longitude: number;
  title?: string;
}

// Ensure yeh bhi exported hai
export interface NitroOpenMapProps extends HybridViewProps {
  color: string;
  latitude?: number;
  longitude?: number;
  zoom?: number;
  mapStyle?: string;
  markers?: Marker[];
}

export interface NitroOpenMapMethods extends HybridViewMethods {}

export type NitroOpenMap = HybridView<NitroOpenMapProps, NitroOpenMapMethods>;
