import { getHostComponent } from 'react-native-nitro-modules';
const NitroOpenMapConfig = require('../nitrogen/generated/shared/json/NitroOpenMapConfig.json');
import type {
  NitroOpenMapMethods,
  NitroOpenMapProps,
} from './NitroOpenMap.nitro';

export const NitroOpenMapView = getHostComponent<
  NitroOpenMapProps,
  NitroOpenMapMethods
>('NitroOpenMap', () => NitroOpenMapConfig);
