// // import { View, type ColorValue, type ViewProps } from 'react-native';

// // type Props = ViewProps & {
// //   color?: ColorValue;
// //   latitude?: number;
// //   longitude?: number;
// // };

// // export function NitroOpenMapView({ color, style, ...rest }: Props) {
// //   return <View {...rest} style={[style, { backgroundColor: color }]} />;
// // }
// import { View, type ViewProps } from 'react-native';
// import type { NitroOpenMapProps } from './NitroOpenMap.nitro';

// export type MapProps = ViewProps & NitroOpenMapProps;

// export function NitroOpenMapView(props: MapProps) {
//   return <View {...(props as any)} />;
// }
import { getHostComponent } from 'react-native-nitro-modules';
import type {
  NitroOpenMapMethods,
  NitroOpenMapProps,
} from './NitroOpenMap.nitro';

const NitroOpenMapConfig = require('../nitrogen/generated/shared/json/NitroOpenMapConfig.json');

export const NitroOpenMapView = getHostComponent<
  NitroOpenMapProps,
  NitroOpenMapMethods
>('NitroOpenMap', () => NitroOpenMapConfig);
