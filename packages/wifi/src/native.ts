import {
  NativeEventEmitter,
  NativeModules,
  Platform,
  PermissionsAndroid
} from "react-native";
import { WifiInterface } from "./types";

const WifiNativeModule = NativeModules.Wifi;

if (!WifiNativeModule) {
  throw new Error(`blem: Native Module is null. Steps to fix:
• Run \`react-native-link react-native-android-wake-lock\` in the project root
• Rebuild and run the app
• Manually link the library if necessary
• If you're getting this error while testing, you didn't read the README. #shame
If none of these fix the issue, open an issue on Github: https://github.com/gretzky/react-native-iot-tools`);
}

let nativeEventEmitter: NativeEventEmitter | null = null;

export const RNIoTWifi: WifiInterface = {
  get eventEmitter(): NativeEventEmitter {
    if (!nativeEventEmitter) {
      nativeEventEmitter = new NativeEventEmitter(WifiNativeModule);
    }

    return nativeEventEmitter;
  },
  addEventListener(event, callback) {
    return this.eventEmitter.addListener(event, data => callback(data));
  },
  removeEventListener() {
    return this.eventEmitter.remove();
  },
  getCurrentNetwork() {
    return WifiNativeModule.getCurrentNetwork();
  },
  connectToNetwork(options) {
    return WifiNativeModule.connectToNetwork(options);
  },
  disconnectFromNetwork(options) {
    return WifiNativeModule.disconnectFromNetwork(options);
  },
  requestLocationPermissions(options) {
    if (Platform.OS === "android") {
      return PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
        {
          title: options?.permissionRequestTitle ?? "Allow location access",
          message:
            options?.permissionRequestMessage ??
            "Location access is required for finding and connecting to wifi networks",
          buttonNeutral:
            options?.permissionRequestButtonNeutralText ?? "Ask again later",
          buttonNegative:
            options?.permissionRequestButtonNegativeText ?? "Cancel",
          buttonPositive:
            options?.permissionRequestButtonPositiveText ?? "Allow access"
        }
      );
    }
    return WifiNativeModule.requestLocationPermissions(options);
  },
  getConfiguredNetworks() {
    return WifiNativeModule.getConfiguredNetworks();
  },
  isConnectedToNetwork(options) {
    return WifiNativeModule.isConnectedToNetwork(options);
  },
  handleWifiLock(options) {
    if (Platform.OS === "ios") {
      return;
    }
    return WifiNativeModule.handleWifiLock(options);
  },
  isWifiLocked() {
    if (Platform.OS === "ios") {
      return;
    }
    return WifiNativeModule.isWifiLocked();
  },
  scanForNetworks() {
    if (Platform.OS === "ios") {
      return;
    }
    return WifiNativeModule.scanForNetworks();
  },
  forceUseNetwork(options) {
    if (Platform.OS === "ios") {
      return;
    }
    return WifiNativeModule.forceUseNetwork(options);
  },
  isWifiEnabled() {
    if (Platform.OS === "ios") {
      return;
    }
    return WifiNativeModule.isWifiEnabled();
  },
  requestSetWifi(options) {
    if (Platform.OS === "ios") {
      return;
    }
    return WifiNativeModule.requestSetWifi(options);
  }
};
