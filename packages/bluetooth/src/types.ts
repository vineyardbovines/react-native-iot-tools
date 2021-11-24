import { EmitterSubscription, NativeEventEmitter } from "react-native";

export enum BufferTypes {
  BIGINT64_BE,
  BIGINT64_LE,
  BIGUINT64_BE,
  BIGUINT64_LE,
  DOUBLE_BE,
  DOUBLE_LE,
  FLOAT_BE,
  FLOAT_LE,
  INT8,
  UINT8,
  INT16_BE,
  INT16_LE,
  UINT16_BE,
  UINT16_LE,
  INT32_BE,
  INT32_LE,
  UINT32_BE,
  UINT32_LE,
  INT_BE,
  INT_LE,
  UINT_BE,
  UINT_LE,
  STRING,
}
export type BufferTypesType = `${BufferTypes}`
export type BufferType = BufferTypesType | BufferTypes

export type ReadReturnData = Buffer | number | bigint | string

export enum DeviceConnectionStates {
  disconnected,
  connecting,
  connected,
  disconnecting,
}
export type DeviceConnectionStateTypes = `${DeviceConnectionStates}`
export type DeviceConnectionState = DeviceConnectionStateTypes | DeviceConnectionStates

export enum BluetoothErrors {
  unauthorized,
  bluetoothDisabled,
  bluetoothUnknown,
  bluetoothUnsupported,
  invalidUUID,
  deviceNotFound,
  deviceNotConnected,
  serviceNotFound,
  characteristicNotFound,
  couldNotConnect,
  couldNotDisconnect,
  permissionRestricted,
  permissionDenied,
  permissionNotDetermined,
  serviceUUIDsRequired,
  invalidWriteData,
  noDeviceProvided,
  notPermittedForType,
  noProtocol,
  parseStreamFail,
  readFail,
}
export type BluetoothErrorsType = `${BluetoothErrors}`
export type BluetoothError = BluetoothErrors | BluetoothErrorsType

export enum BluetoothEvents {
  discover = "BluetoothDiscover",
  stateChange = "BluetoothStateChange",
  connect = "BluetoothConnect",
  disconnect = "BluetoothDisconnect",
  connectFail = "BluetoothConnectFail",
  connectionEvent = "BluetoothConnectionEvent",
  read = "BluetoothRead",
  write = "BluetoothWrite",
  error = "BluetoothError",
  rssi = "BluetoothRSSI",
  servicesModified = "BluetoothServicesModified",
  discoverServices = "BluetoothDiscoverServices",
  discoverCharacteristics = "BluetoothDiscoverCharacteristics",
  notificationStateChange = "BluetoothNotificationStateChange",
  deviceNameChange = "BluetoothDeviceNameChange",
}
export type BluetoothEventsType = `${BluetoothEvents}`
export type BluetoothEvent = BluetoothEvents | BluetoothEventsType

export enum BluetoothStates {
  permissionAllowedAlways = "permissionAllowedAlways",
  permissionDenied = "permissionDenied",
  permissionRestricted = "permissionRestricted",
  permissionNotDetermined = "permissionNotDetermined",
  unavailable = "unavailable",
  unauthorized = "unauthorized",
  unknown = "unknown",
  unsupported = "unsupported",
  resetting = "resetting",
  poweredOff = "poweredOff",
  poweredOn = "poweredOn",
  ready = "ready"
}
export type BluetoothStateType = `${BluetoothStates}`
export type BluetoothState = BluetoothStates | BluetoothStateType

export type ServiceWithCharacteristics = {
  [key: string]: string[];
};

export type BleDevice = {
  uuid: string;
  name: string;
  servicesAndCharacteristics?: ServiceWithCharacteristics;
  state: DeviceConnectionState;
  rssi?: number;
  ancsAuthorized?: boolean;
};

type Identifier = { peripheralUUID: string }

export type WithServiceUUIDs = {
  serviceUUIDs?: string[];
};

export type ScanOptions = {
  allowDuplicates?: boolean;
  scanTimeoutSeconds?: number;
}

export type ConnectionOptions = {
  notifyOnConnect?: boolean;
  notifyOnDisconnect?: boolean;
  notifyOnNotification?: boolean;
  startDelay?: boolean;
  requireANCS?: boolean;
  enableTransportBridging?: boolean;
};

export type ConnectOptions = Identifier &
      WithServiceUUIDs &
      ConnectionOptions & { shouldDiscover?: boolean }


export type ConnectedDevicesOptions = Required<WithServiceUUIDs>

export type DeviceInteractionOptions = {
  serviceUUID: string;
  characteristicUUID: string;
};

export type ReadDeviceOptions = Identifier &
      DeviceInteractionOptions & {
        dataType?: BufferTypes;
        dataOffset?: number;
        dataByteLength?: number;
      }

export type WriteDeviceOptions = Identifier & DeviceInteractionOptions & {
  writeData: string;
  withResponse?: boolean;
};

export type SetNotifyOptions = Identifier & DeviceInteractionOptions & { shouldNotify: boolean }

export type FetchServicesCharacteristicsOptions =  Identifier & Required<WithServiceUUIDs>

export type EventData = {
  timestamp: string;
  message: string;
  device: BleDevice;
  [key: string]: unknown;
};

type PromiseWithError<T> = Promise<T | BluetoothError>

export interface BluetoothInterface {
  get eventEmitter(): NativeEventEmitter;
  addListener(
    event: BluetoothEvent,
    callback: (e: EventData) => void
  ): EmitterSubscription;
  removeListener(): void;
  getBluetoothStatus(): PromiseWithError<BluetoothState>;
  startDiscovery(options: ScanOptions): PromiseWithError<void>;
  stopDiscovery(options: ScanOptions): PromiseWithError<void>;
  getDiscoveredDevices(
  ): PromiseWithError<BleDevice>;
  connectToDevice(
    options: ConnectOptions
  ): PromiseWithError<boolean>;
  getConnectedDevices(
    options: ConnectedDevicesOptions
  ): PromiseWithError<BleDevice>;
  disconnectFromDevice(options: Identifier): PromiseWithError<boolean>;
  readFromDevice(
    options: ReadDeviceOptions
  ): PromiseWithError<unknown>;
  writeToDevice(
    options: WriteDeviceOptions
  ): PromiseWithError<boolean>;
  setCharacteristicNotify(
    options: SetNotifyOptions
  ): PromiseWithError<void>;
  fetchServicesAndCharacteristics(
    options: FetchServicesCharacteristicsOptions
  ): PromiseWithError<void>;
  fetchRSSI(options: Identifier): PromiseWithError<void>;
  isDeviceConnected(options: Identifier): PromiseWithError<boolean>;
  getDevice(
    options: Identifier
  ): PromiseWithError<BleDevice>;
}
