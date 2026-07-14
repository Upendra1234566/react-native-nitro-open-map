import type {
  HybridView,
  HybridViewMethods,
  HybridViewProps,
} from 'react-native-nitro-modules';

export interface NitroOpenMapProps extends HybridViewProps {
  color: string;
}
export interface NitroOpenMapMethods extends HybridViewMethods {}

export type NitroOpenMap = HybridView<
  NitroOpenMapProps,
  NitroOpenMapMethods
>;
