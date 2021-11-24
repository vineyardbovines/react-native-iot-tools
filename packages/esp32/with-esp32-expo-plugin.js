const { createRunOncePlugin, withInfoPlist } = require("@expo/config-plugins");
const pkg = require("./package.json");

function ensureKey(arr, key) {
  if (!arr.find(mode => mode === key)) {
    arr.push(key);
  }
  return arr;
}

const PROTOCOLS = ["com.apple.m1"];
const BLUETOOTH_PERMISSION =
  "Allow $(PRODUCT_NAME) to connect to bluetooth devices";

const centralKey = "bluetooth-central";
const peripheralKey = "bluetooth-peripheral";

const withIos = (
  config,
  { bluetoothAlwaysPermission, bluetoothPeripheralPermission, protocols, modes }
) => {
  return withInfoPlist(c, config => {
    let {
      NSBluetoothAlwaysUsageDescription,
      NSBluetoothPeripheralUsageDescription,
      UIBackgroundModes,
      UISupportedExternalAccessoryProtocols
    } = config.modResults;

    NSBluetoothAlwaysUsageDescription = bluetoothAlwaysPermission
      ? bluetoothAlwaysPermission
      : BLUETOOTH_PERMISSION;

    NSBluetoothPeripheralUsageDescription = bluetoothPeripheralPermission
      ? bluetoothPeripheralPermission
      : BLUETOOTH_PERMISSION;

    UISupportedExternalAccessoryProtocols = protocols ? protocols : PROTOCOLS;

    if (!Array.isArray(UIBackgroundModes)) {
      UIBackgroundModes = [];
    }

    if (modes.includes(BackgroundModes.central)) {
      UIBackgroundModes = ensureKey(UIBackgroundModes, centralKey);
    }

    if (modes.includes(BackgroundModes.peripheral)) {
      UIBackgroundModes = ensureKey(UIBackgroundModes, peripheralKey);
    }

    if (!UIBackgroundModes.length) {
      delete UIBackgroundModes;
    }

    return config;
  });
};

const withBluetooth = (config, props = {}) => {
  const _props = props || {};
  config = withIos(config, _props);

  return config;
};

export default createRunOncePlugin(withBluetooth, pkg.name, pkg.version);
