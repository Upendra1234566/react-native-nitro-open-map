// import { View, type ColorValue, type ViewProps } from 'react-native';

// type Props = ViewProps & {
//   color?: ColorValue;
// };

// export function NitroOpenMapView({ color, style, ...rest }: Props) {
//   return <View {...rest} style={[style, { backgroundColor: color }]} />;
// }

import { View, type ColorValue, type ViewProps } from 'react-native';

type Props = ViewProps & {
  color?: ColorValue;
  latitude?: number;
  longitude?: number;
};

export function NitroOpenMapView({ color, style, ...rest }: Props) {
  return <View {...rest} style={[style, { backgroundColor: color }]} />;
}
