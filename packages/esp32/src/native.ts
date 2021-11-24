import { NativeEventEmitter, NativeModules } from "react-native";
import { encode } from "base-64";
import { ESP32Interface } from "./types";

const ESP32NativeModule = NativeModules.ESP32;

if (!ESP32NativeModule) {
  throw new Error(`ESP32: Native Module is null. Steps to fix:
• Run \`react-native-link @react-native-iot-tools/esp32\` in the project root
• Rebuild and run the app
• Manually link the library if necessary
• If you're getting this error while testing, you didn't read the README. #shame
If none of these fix the issue, open an issue on Github: https://github.com/gretzky/react-native-iot-tools`);
}

let nativeEventEmitter: NativeEventEmitter | null = null;

export const RNIoTESP32: ESP32Interface = {
  get eventEmitter(): NativeEventEmitter {
    if (!nativeEventEmitter) {
      nativeEventEmitter = new NativeEventEmitter(ESP32NativeModule);
    }

    return nativeEventEmitter;
  },
  addListener(event, callback) {
    return this.eventEmitter.addListener(event, data => callback(data));
  },
  removeListener() {
    return this.eventEmitter.remove();
  },
  startDiscovery(options) {
    return ESP32NativeModule.startDiscovery(options);
  },
  stopDiscovery() {
    return ESP32NativeModule.stopDiscovery();
  },
  refreshDiscoveredDevices() {
    return ESP32NativeModule.refreshDiscoveredDevices();
  },
  getDiscoveredDevices() {
    return ESP32NativeModule.getDiscoveredDevices();
  },
  connectToDevice(options) {
    return ESP32NativeModule.connectToDevice(options);
  },
  disconnectFromDevice() {
    return ESP32NativeModule.disconnectFromDevice();
  },
  scanForWifiNetworks() {
    return ESP32NativeModule.scanForWifiNetworks();
  },
  provisionDevice(options) {
    return ESP32NativeModule.provisionDevice(options);
  },
  sendDataToDevice(options) {
    const { data, ...rest } = options;
    return ESP32NativeModule.sendDataToDevice({
      ...rest,
      data: encode(data)
    });
  }
};
