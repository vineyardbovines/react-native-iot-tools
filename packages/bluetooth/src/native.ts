import { NativeEventEmitter, NativeModules } from "react-native";
import { encode } from "base-64";
import { ReadReturnData } from ".";
import { BluetoothInterface } from "./types";
import { handleBufferData } from "./util";

const BluetoothNativeModule = NativeModules.Bluetooth;

if (!BluetoothNativeModule) {
  throw new Error(`bluetooth: Native Module is null. Steps to fix:
• Run \`react-native-link @react-native-iot-tools/bluetooth\` in the project root
• Rebuild and run the app
• Manually link the library if necessary
• If you're getting this error while testing, you didn't read the README. #shame
If none of these fix the issue, open an issue on Github: https://github.com/gretzky/react-native-iot-tools`);
}

let nativeEventEmitter: NativeEventEmitter | null = null;

export const RNIoTBluetooth: BluetoothInterface = {
  get eventEmitter(): NativeEventEmitter {
    if (!nativeEventEmitter) {
      nativeEventEmitter = new NativeEventEmitter(BluetoothNativeModule);
    }

    return nativeEventEmitter;
  },
  addListener(event, callback) {
    return this.eventEmitter.addListener(event, data => callback(data));
  },
  removeListener() {
    return this.eventEmitter.remove();
  },
  getBluetoothStatus() {
    return BluetoothNativeModule.getBluetoothStatus();
  },
  startDiscovery(options) {
    return BluetoothNativeModule.startDiscovery({ options });
  },
  stopDiscovery() {
    return BluetoothNativeModule.stopDiscovery();
  },
  getDiscoveredDevices() {
    return BluetoothNativeModule.getDiscoveredDevices();
  },
  connectToDevice(options) {
    return BluetoothNativeModule.connectToDevice(options);
  },
  getConnectedDevices(options) {
    return BluetoothNativeModule.getConnectedDevices(options);
  },
  disconnectFromDevice(options) {
    return BluetoothNativeModule.disconnectFromDevice(options);
  },
  readFromDevice(options) {
    return BluetoothNativeModule.fetchServicesAndCharacteristics().then(() => {
      return BluetoothNativeModule.readCharacteristic(options).then(
        (buffer: Buffer): ReadReturnData => {
          if (!options.dataType) {
            return buffer as Buffer;
          } else {
            return handleBufferData({
              buffer,
              dataType: options.dataType,
              offset: options.dataOffset,
              byteLength: options.dataByteLength
            });
          }
        }
      );
    });
  },
  writeToDevice(options) {
    return BluetoothNativeModule.fetchServicesAndCharacteristics().then(() => {
      const { writeData, ...rest } = options;

      return BluetoothNativeModule.writeToDevice({
        ...rest,
        writeData: encode(writeData)
      });
    });
  },
  setCharacteristicNotify(options) {
    return BluetoothNativeModule.fetchServicesAndCharacteristics().then(() => {
      return BluetoothNativeModule.setCharacteristicNotify(options);
    });
  },
  fetchServicesAndCharacteristics(options) {
    return BluetoothNativeModule.fetchServicesAndCharacteristics(options);
  },
  fetchRSSI() {
    return BluetoothNativeModule.fetchRSSI();
  },
  isDeviceConnected(options) {
    return BluetoothNativeModule.isDeviceConnected(options);
  },
  getDevice(options) {
    return BluetoothNativeModule.getDevice(options);
  }
};
