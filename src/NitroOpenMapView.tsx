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
