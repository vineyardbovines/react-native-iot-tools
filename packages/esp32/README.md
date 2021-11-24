# @react-native-iot-tools/esp32

React Native library for interfacing with ESP32 devices. **Currently iOS only.**

| Platform | SDK                                                                      | Minimum version requirement |
| -------- | ------------------------------------------------------------------------ | --------------------------- |
| iOS      | [CoreBluetooth](https://developer.apple.com/documentation/corebluetooth) | 12.0                        |

## Getting Started

If you're using Expo (SDK 42 or above), [click here](#using-expo-).

Otherwise, install the library using yarn or npm:

```bash
yarn add @react-native-iot-tools/bluetooth
// or
npm install @react-native-iot-tools/bluetooth --save
```

### Using React Native >= 0.60

The package will be linked automatically (see [autolinking](https://github.com/react-native-community/cli/blob/master/docs/autolinking.md)). Linking Manually is not required.

- **iOS**:

  `npx pod-install` # Install CocoaPods (required)

  Add the permission strings in your `Info.plist`. **Your app will crash without these.**

  ```xml
  <key>NSBluetoothAlwaysUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSBluetoothPeripheralUsageDescription</key>
  <string>YOUR TEXT</string>
  ```

### Using React Native < 0.60

You then need to link the native parts of the library for the platforms you are using. The easiest way to link the library is using the CLI tool by running this command from the root of your project:

```bash
react-native link @react-native-iot-tools/esp32
```

If you can't or don't want to use the CLI tool, you can also manually link the library using the instructions below (click on the arrow to show them):

<details>
<summary>Manually link the library on iOS</summary>

Either follow the [instructions in the React Native documentation](https://facebook.github.io/react-native/docs/linking-libraries-ios#manual-linking) to manually link the framework or link using [Cocoapods](https://cocoapods.org) by adding this to your `Podfile`:

```ruby
pod 'esp32', :path => '../node_modules/react-native-iot-tools/esp32'
```

Make the following changes:

##### Info.plist

Add the permission strings in your `Info.plist`. **Your app will crash without these.**

```plist
<key>NSBluetoothAlwaysUsageDescription</key>
<string>YOUR TEXT</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>YOUR TEXT</string>
```

</details>

### Using Expo (SDK >=42)

Install the library

```bash
expo install @react-native-iot-tools/bluetooth
```

Add the config plugin to the plugins array of your `app.json` or `app.config.js`

```
{
  "expo": {
    "plugins": ["@react-native-iot-tools/bluetooth/with-bluetooth"]
  }
}
```

The plugin provides props for customization. Every time you change the props, you'll need to rebuild (and `prebuild`) the native app.

| Prop                        | Description                                                                                                                                                                                   |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `modes`                     | Adds [`UIBackgroundModes`](https://developer.apple.com/documentation/bundleresources/information_property_list/uibackgroundmodes) to `Info.plist`                                             |
| `bluetoothAlwaysPermission` | Sets the [`NSBluetoothAlwaysUsageDescription`](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription) in `Info.plist`         |
| `bluetoothPeripheralUsage`  | Sets the [`NSBluetoothPeripheralUsageDescription`](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothperipheralusagedescription) in `Info.plist` |

**Example**

```json
{
  "expo": {
    "plugins": [
      [
        "react-native-iot-tools/bluetooth/with-bluetooth",
        {
          "modes": ["peripheral", "central", "external-accessory"],
          "bluetoothAlwaysPermission": "Allow $(PRODUCT_NAME) to connect to bluetooth devices",
          "bluetoothPeripheralPermission": "Allow $(PRODUCT_NAME) to connect to bluetooth devices"
        }
      ]
    ]
  }
}
```

## Methods

### `startDiscovery(options?: ScanOptions): Promise<boolean>`

Discovers ESP32 devices over Bluetooth. Returns true when discovery completes. The [`.discover`](#-discover) listener will emit an event when a device is discovered.

| Parameter | Type     | Description               | Default                      |
| --------- | -------- | ------------------------- | ---------------------------- |
| `prefix`  | `string` | Device prefix to scan for | `""` (looks for all devices) |

```ts
React.useEffect(() => {
  ESP32.startDiscovery();
}, []);

React.useEffect(() => {
  ESP32.addListener(ESP32Events.discover, (eventPayload: ESP32EventData) =>
    console.log(eventPayload)
  );

  return () => {
    ESP32.removeListener(ESP32Events.discover);
  };
}, []);
```

### `stopDiscovery(): Promise<boolean>`

Stops device discovery. Returns true when discovery is stopped.

```ts
React.useEffect(() => {
  ESP32.stopDiscovery();
}, []);
```

### `refreshDiscoveredDevices(): Promise<boolean>`

Refreshes the list of discovered ESP32 devices. Returns true when discovery refreshes. The [`.discover`](#-discover) listener will emit an event when devices are refreshed.

```ts
React.useEffect(() => {
  ESP32.refreshDiscoveredDevices();
}, []);

React.useEffect(() => {
  ESP32.addListener(ESP32Events.discover, (eventPayload: ESP32EventData) =>
    console.log(eventPayload)
  );

  return () => {
    ESP32.removeListener(ESP32Events.discover);
  };
}, []);
```

### `getDiscoveredDevices(): Promise<Device[]>`

Returns a list of discovered ESP32 devices.

```ts
const discoveredDevices = ESP32.getDiscoveredDevices();
```

### `connectToDevice(options: ConnectOptions): Promise<boolean>`

Connects to a given ESP32 device. Returns true if succesfully connected. The [`.connectionEvent`](#-connectionEvent) listener will emit an event with the device object when the device connects.

| Parameter           | Type           | Description              | Default                                 |
| ------------------- | -------------- | ------------------------ | --------------------------------------- |
| `name`              | `string`       | The name of the device   | **Required**                            |
| `transportMode`     | `"ap" | "ble"` | Mode of transport        | `"ble"`                                 |
| `proofOfPossession` | `string`       | A device-specific secret | `""`                                    |
| `apPassword`        | `string`       | Access point password    | **Required if `transportMode == "ap"`** |

```ts
React.useEffect(() => {
  // over BLE
  ESP32.connectToDevice(
    name: "device"
  )

  // over access point
  ESP32.connectToDevice(
    name: "device",
    transportMode: TransportMode.ap, // can also "ap"
    apPassword: "hunter2"
  )
}, [])

React.useEffect(() => {
  ESP32.addListener(
    ESP32Events.connect,
    (eventPayload: ESP32EventData) => console.log(eventPayload)
  )

  return () => {
    ESP32.removeListener(ESP32Events.connect)
  }
})
```

### `disconnectFromDevice(): Promise<boolean>`

Disconnects from a given ESP32 device. The [`.connectionEvent`](#-connectionEvent) listener will emit an event when the device disconnects.

```ts
React.useEffect(() => {
  ESP32.disconnectFromDevice();
}, []);

React.useEffect(() => {
  ESP32.addListener(ESP32Events.disconnect, (eventPayload: ESP32EventData) =>
    console.log(eventPayload)
  );

  return () => {
    ESP32.removeListener(ESP32Events.disconnect);
  };
}, []);
```

### `scanForWifiNetworks(): Promise<boolean>`

Tells the ESP32 device to scan for nearby wifi networks. Returns true when the scan has completed, throws an error if an ESP32 device is not found or connected. The [`.discoverWifiNetworks`]() listener emits wifi network objects when discovered.

```ts
React.useEffect(() => {
  ESP32.scanForWifiNetworks();
}, []);

React.useEffect(() => {
  ESP32.addEventListener(
    ESP32Events.discoverWifiNetworks,
    (eventPayload: ESP32EventData) => console.log(eventPayload)
  );
}, []);
```

### `provisionDevice(options: ProvisionDeviceOptions): Promise<boolean>`

Provisions a device with wifi credentials. Returns true when provisioned, errors out if an ESP32 device is not found or connected.

| Parameter    | Type     | Description           | Default      |
| ------------ | -------- | --------------------- | ------------ |
| `ssid`       | `string` | wifi network SSID     | **Required** |
| `passphrase` | `string` | wifi network password | **Required** |

```ts
React.useEffect(() => {
  ESP32.provisionDevice({
    ssid: "Bill Gates 5G COVID Spreader",
    passphrase: "hunter2"
  });
}, []);
```

### `sendDataToDevice(options: SendDataOptions): Promise<Data>`

Sends data to a device via an endpoint. Returns the status code sent from the device when data is received.

| Parameter  | Type     | Description                                | Default      |
| ---------- | -------- | ------------------------------------------ | ------------ |
| `endpoint` | `string` | The endpoint on the device to send data to | **Required** |
| `data`     | `string` | Data to send to the device                 | **Required** |

```ts
React.useEffect(() => {
  ESP32.sendDataToDevice({
    endpoint: "/some/endpoint",
    data: "hunter2"
  });
}, []);
```

## Listeners

Most methods have a corresponding listener and will contain a key-value pair with device information.

```ts
type ESP32Device = {
  name: string;
  connectionStatus: DeviceConnectivity;
  proofOfPossession?: string;
  capabilities?: string[];
  security: Security;
};

export enum DeviceConnectivity {
  connected = 1,
  connectFail = 2,
  disconnected = 3
}

enum Security {
  unsecure,
  secure
}
```

Some events will have extra keys if necessary.

Listeners can be added/removed with `ESP32.addListener` and `ESP32.removeListener`, respecfully. To get the event emitter itself, you can call `ESP32.eventEmitter`.

### `ESP32Event`

Potential emitted events from the listeners. Available as an enum (`ESP32Events`) or a string literal type.

| Name                        | Listener                                          |
| --------------------------- | ------------------------------------------------- |
| `ESP32DiscoverDevices`      | [`.discoverDevices`](#-discoverDevices)           |
| `ESP32DiscoverWifiNetworks` | [`.discoverWifiNetworks`](#-discoverWifiNetworks) |
| `ESP32Connect`              | [`.connect`](#-connect)                           |
| `ESP32ConnectFail`          | [`.connectFail`](#-connectFail)                   |
| `ESP32Disconnect`           | [`.disconnect`](#-disconnect)                     |
| `ESP32Provision`            | [`.provision`](#-provision)                       |

### `.discoverDevices`

Listens for discovered ESP32 devices over Bluetooth.

```tsx
React.useEffect(() => {
  ESP32.addListener(
    ESP32Events.discoverDevices,
    (eventPayload: ESP32EventData) => console.log(eventPayload)
  );

  return () => {
    ESP32.removeListener();
  };
}, []);
```

### `.discoverWifiNetworks`

Listens for discovered wifi networks during a scan. Emits a key-value pair containing a wifi network object.

```tsx
React.useEffect(() => {
  ESP32.addListener(
    ESP32Events.discoverWifiNetworks,
    (eventPayload: ESP32EventData) => console.log(eventPayload)
  );

  return () => {
    ESP32.removeListener();
  };
}, []);
```

### `.connect`

Listens for device connections.

```tsx
React.useEffect(() => {
  ESP32.addListener(ESP32Events.connect, (eventPayload: ESP32EventData) =>
    console.log(eventPayload)
  );

  return () => {
    ESP32.removeListener();
  };
}, []);
```

### `.connectFail`

Listens for device connection failures.

```tsx
React.useEffect(() => {
  ESP32.addListener(ESP32Events.connectFail, (eventPayload: ESP32EventData) =>
    console.log(eventPayload)
  );

  return () => {
    ESP32.removeListener();
  };
}, []);
```

### `.disconnect`

Listens for device disconnections.

```tsx
React.useEffect(() => {
  ESP32.addListener(ESP32Events.disconnect, (eventPayload: ESP32EventData) =>
    console.log(eventPayload)
  );

  return () => {
    ESP32.removeListener();
  };
}, []);
```

### `.provision`

Listens for device provision events.

```tsx
React.useEffect(() => {
  ESP32.addListener(ESP32Events.provision, (eventPayload: ESP32EventData) =>
    console.log(eventPayload)
  );

  return () => {
    ESP32.removeListener();
  };
}, []);
```

## Acknowledgements

- [ESPProvision](https://espressif.github.io/esp-idf-provisioning-ios/index.html)
