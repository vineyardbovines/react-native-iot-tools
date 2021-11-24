import { EmitterSubscription, NativeEventEmitter } from "react-native";

export enum WifiErrors {
  unknown,
  unavailable,
  pending,
  systemError,
  internalError,
  appNotInForeground,
  locationServicesDisabled,
  locationPermissionDenied,
  locationPermissionRestricted,
  invalid,
  invalidSSID,
  invalidSSIDPrefix,
  invalidSettings,
  ssidNotFound,
  prefixRequiresPassphrase,
  invalidPassphrase,
  userDenied,
  networkNotFound,
  couldNotConnect,
  couldNotDisconnect,
  alreadyAssociated
}

export enum WifiEvents {
  connected,
  disconnected
}

export enum LocationPermissionTypes {
  whileInUse = "whileInUse",
  always = "always"
}

export type ConnectOptions = {
  ssid: string;
  passphrase?: string;
  isWEP?: boolean;
  shouldConnectByPrefix?: boolean;
};

export type DisconnectOptions = {
  ssid: string;
};

export type RequestLocationPermissionsOptions = {
  type?: LocationPermissionTypes;
  permissionRequestTitle?: string
  permissionRequestMessage?: string
  permissionRequestButtonNeutralText?: string
  permissionRequestButtonNegativeText?: string
  permissionRequestButtonPositiveText?: string
};

export type WifiEventData = {
  timestamp: string
  message: string
  [key: string]: unknown
}

// https://developer.apple.com/documentation/networkextension/nehotspoteapsettings/eaptype
export enum EAPTypes {
  TLS = 13,
  TTLS = 21,
  PEAP = 25,
  FAST = 43
}

export enum TLSVersion {
  _1_0,
  _1_1,
  _1_2
}

export enum TTLSInnerAuthTypes {
  PAP,
  CHAP,
  MSCHAP,
  MSCHAPv2,
  EAP
}


export type EAPSettings = {
  isTLSClientCertificateRequired?: boolean
  trustedServerNames: string[]
  supportedEAPTypes: EAPTypes[]
  username?: string // optional for TLS, required for ttls/fast/peap -- min 1 max 253
  password?: string // // optional for TLS, required for ttls/fast/peap -- min 1 char max 64 char
  preferredTLSVersion?: TLSVersion
  outerIdentity?: string // ttls/peap/fast only
  ttlsInnerAuthenticationType: TTLSInnerAuthTypes
}

export type HS20Settings = {
  domainName: string // 1-253 chars
  roamingEnabled: boolean 
}

export type ForceUseNetworkOptions = {
  shouldForceWifi: boolean
  networkHasNoInternet: boolean
}

export enum WifiState {
  disabled,
  enabled
}

export type Network = {
  ssid: string
  bssid?: string
  rssi?: number
  frequency?: number
  ipAddress?: string
}

export interface WifiInterface {
  get eventEmitter(): NativeEventEmitter
  addEventListener(event: WifiEvents, callback: (e: EventData) => void): EmitterSubscription
  removeEventListener(): void;
  getCurrentNetwork(): Promise<string>;
  connectToNetwork(options: ConnectOptions): Promise<string>;
  disconnectFromNetwork(options: DisconnectOptions): Promise<boolean>;
  requestLocationPermissions(
    options?: RequestLocationPermissionsOptions
  ): Promise<void>;
  getConfiguredNetworks(): Promise<string[]>;
  getCurrentNetwork(): Promise<string>;
  isConnectedToNetwork(options: { ssid: string }): Promise<boolean>;
  handleWifiLock(options: { shouldLock: boolean }): Promise<boolean>
  isWifiLocked(): Promise<boolean>
  scanForNetworks(): Promise<Network[]>
  forceUseNetwork(options: ForceUseNetworkOptions): Promise<void>
  requestSetWifi(options: { shouldEnable: boolean }): Promise<boolean>
  isWifiEnabled(): Promise<WifiState>
}
