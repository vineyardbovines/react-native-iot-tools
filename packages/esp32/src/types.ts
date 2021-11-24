import { EmitterSubscription, NativeEventEmitter } from "react-native"

export enum ESP32Events {
  discover = "ESP32Discover",
  discoverWifiNetworks = "ESP32DiscoverWifiNetworks",
  connect = "ESP32Connect",
  provision = "ESP32Provision",
}

export enum DeviceConnectivity {
  connected = 1,
  connectFail = 2,
  disconnected = 3
}

export enum ProvisioningStatus {
  initFailed = 0,
  configFailed = 2,
  configApplied = 3,
  applyFailed = 4,
  completed = 5,
  failed = 6
}

enum Security {
  unsecure,
  secure,
}

export type BluetoothScanOptions = {
  prefix?: string
}

enum Protocols {
  bluetooth,
  wifi
}

export type ConnectToDeviceOptions = {
  name: string
  proofOfPossession?: string
  password?: string
  protocol: Protocols
}

export type ProvisionDeviceOptions = {
  ssid: string
  passphrase: string
}

export type SendDataOptions = {
  endpoint: string
  data: string
}

export type Device = {
  name: string
  connectionStatus: DeviceConnectivity
  proofOfPossession?: string
  capabilities?: string[]
  security: Security
}

export enum WifiAuthModes {
  open,
  wep,
  wpaPsk,
  wpa2Psk,
  wpaWpa2Psk,
  wpa2Enterprise,
  unrecognized
}

export type WifiNetwork = {
  ssid: string
  auth: WifiAuthModes
  rssi: number
}

export type ESP32Error = {
  error: string
}

type EventType = "device" | "devices" | "error"

type EventDataKey = {
  [Property in keyof EventType]: Device | Device[] | string
}

export type ESP32EventData = {
  message: string
} & EventDataKey

export interface ESP32Interface {
  get eventEmitter(): NativeEventEmitter
  addListener(event: ESP32Events, callback: (e: ESP32EventData) => void): EmitterSubscription
  removeListener(): void
  startDiscovery(options?: BluetoothScanOptions): Promise<boolean>
  stopDiscovery(): Promise<boolean>
  refreshDiscoveredDevices(): Promise<boolean>
  getDiscoveredDevices(): Promise<Device[]>
  connectToDevice(options: ConnectToDeviceOptions): Promise<Device>
  disconnectFromDevice(): Promise<boolean>
  scanForWifiNetworks(): Promise<boolean>
  provisionDevice(options: ProvisionDeviceOptions): Promise<{status: ProvisioningStatus, device: Device}>
  sendDataToDevice(options: SendDataOptions): Promise<void>
}
