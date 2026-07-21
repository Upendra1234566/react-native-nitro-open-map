// import { getHostComponent } from 'react-native-nitro-modules';

// const NitroOpenMapConfig = require('../nitrogen/generated/shared/json/NitroOpenMapConfig.json');

// import type {
//   NitroOpenMapMethods,
//   NitroOpenMapProps,
// } from './NitroOpenMap.nitro';

// export const NitroOpenMapView = getHostComponent<
//   NitroOpenMapProps,
//   NitroOpenMapMethods
// >('NitroOpenMap', () => NitroOpenMapConfig);

import { type ViewProps } from 'react-native';
import { getHostComponent } from 'react-native-nitro-modules';
import type {
  NitroOpenMapMethods,
  NitroOpenMapProps,
  Marker,
} from './NitroOpenMap.nitro';

const NitroOpenMapConfig = require('../nitrogen/generated/shared/json/NitroOpenMapConfig.json');

const NativeMapComponent = getHostComponent<
  NitroOpenMapProps,
  NitroOpenMapMethods
>('NitroOpenMap', () => NitroOpenMapConfig);

export type MapProps = ViewProps & {
  color: string;
  latitude?: number;
  longitude?: number;
  zoom?: number;
  mapStyle?: string;
  markers?: Marker[];
};

export function NitroOpenMapView({ color = '#FFFFFF', ...props }: MapProps) {
  return <NativeMapComponent {...props} color={color} />;
}
