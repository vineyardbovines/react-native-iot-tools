# @react-native-iot-tools/bluetooth

React Native Bluetooth module for Bluetooth devices. **Currently iOS only**.

| Platform | SDK                                                                      | Minimum version requirement |
| -------- | ------------------------------------------------------------------------ | --------------------------- |
| iOS      | [CoreBluetooth](https://developer.apple.com/documentation/corebluetooth) | 12.0                        |

On iOS, there is some crossover behavior with CoreBluetooth implemented for classic devices, [see more here](https://developer.apple.com/documentation/corebluetooth/using_core_bluetooth_classic).

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
react-native link @react-native-iot-tools/bluetooth
```

If you can't or don't want to use the CLI tool, you can also manually link the library using the instructions below (click on the arrow to show them):

<details>
<summary>Manually link the library on iOS</summary>

Either follow the [instructions in the React Native documentation](https://facebook.github.io/react-native/docs/linking-libraries-ios#manual-linking) to manually link the framework or link using [Cocoapods](https://cocoapods.org) by adding this to your `Podfile`:

```ruby
pod 'bluetooth', :path => '../node_modules/react-native-iot-tools/bluetooth'
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

## Usage

You can find full examples in [`examples/`](./examples).

## Methods

### `getBluetoothStatus(): Promise<BluetoothStates | BluetoothError>`

Gets the Bluetooth status (on/off/permission error). Returns one of [BluetoothStates](#BluetoothStates).

```tsx
const status = await Bluetooth.getBluetoothStatus();
```

### `startDiscovery(options: ScanOptions): Promise<void | BluetoothError>`

Start discovering Bluetooth devices. The [`.discover`](#-discover) listener will emit an event when a device is discovered.

This function does not return any devices, so the listener is required if you need to collect device information.

| Parameter         | Type       | Description                                                 | Default                      |
| ----------------- | ---------- | ----------------------------------------------------------- | ---------------------------- |
| `serviceUUIDs`    | `string[]` | An array of service UUIDs on devices you want to scan for.  | `[]` (scans for all devices) |
| `allowDuplicates` | `boolean`  | Whether or not to allow duplicate devices to be discovered. | `false`                      |

```tsx
React.useEffect(() => {
  Bluetooth.startDiscovery();
}, []);

React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.discover,
    (eventPayload: BluetoothEventData) => console.log(eventPayload)
  );

  return () => {
    Bluetooth.removeListener(BluetoothEvents.discover);
  };
}, []);
```

### `stopDiscovery(): Promise<void | BluetoothError>`

Stops the discovery of devices.

```tsx
Bluetooth.stopDiscovery();
```

### `getDiscoveredDevices(): Promise<BleDevice | BluetoothError>`

Gets a list of discovered devices.

```tsx
const discoveredDevices = Bluetooth.getDiscoveredDevices();
```

### `connectToDevice(options: ConnectOptions): Promise<boolean | BluetoothError>`

Connects to a device. Returns a `boolean` for whether or not the device successfully connected. Ther [`.connect`](#-connect) listener will emit an event when the device connects.

**Note:** you must discover devices before connecting to them. If you aren't calling `startDiscovery` before connecting, you can pass the `shouldDiscover` param to this method.

| Parameter                    | Type      | Description                                                                                             | Default      |
| ---------------------------- | --------- | ------------------------------------------------------------------------------------------------------- | ------------ |
| `peripheralUUID`             | `string`  | The UUID of the device to connect to                                                                    | **Required** |
| `notifyOnConnect`            | `boolean` | Display an alert dialog when device connects.                                                           | `false`      |
| `notifyOnDisconnect`         | `boolean` | Display an alert dialog when device disconnects.                                                        | `false`      |
| `notifyOnNotification`       | `boolean` | Display an alert dialog for any notification received from the device.                                  | `false`      |
| `startDelay`                 | `boolean` | Indicate a delay before connecting to the device.                                                       | `false`      |
| `requireANCS`                | `boolean` | **iOS >=13 only**. Require Apple Notification Center Service when connecting to a device.               | `false`      |
| `enableTransportBridgingKey` | `boolean` | **iOS >= 13 only**. Bridge classic Bluetooth technology profiles once the device is connected over BLE. | `false`      |
| `shouldDiscover`             | `boolean` | **BLE, iOS only.** Discover devices before connecting.                                                  | `false`      |

```tsx
React.useEffect(() => {
  // ble
  Bluetooth.connectToDevice({
    peripheralUUID: "xxx-xxx-xxx"
  }).then((isConnected: boolean) => console.log(isConnected));
}, []);

// listener (optional)
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.connect,
    (eventPayload: BluetoothEventData) => console.log(eventPayload)
  );

  return () => {
    Bluetooth.removeListener(BluetoothTypes.connect);
  };
}, []);
```

### `disconnectFromDevice(options: Identifier): Promise<boolean | BluetoothError>`

Disconnects from a given device.

Returns a boolean when the device disconnects. The [`.disconnect`](#-disconnect) listener will emit an event when the device disconnects.

| Parameter        | Type     | Description                          | Default      |
| ---------------- | -------- | ------------------------------------ | ------------ |
| `peripheralUUID` | `string` | The UUID of the device to connect to | **Required** |

```tsx
React.useEffect(() => {
  // ble
  Bluetooth.disconnectFromDevice({
    peripheralUUID: "xxx-xxx-xxx"
  }).then((didDisconnect: boolean) => console.log(didDisconnect));
}, []);

// listener (optional)
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.disconnect,
    (eventPayload: BluetoothEventData) => console.log(eventPayload)
  );

  return () => {
    Bluetooth.removeListener(BluetoothTypes.disconnect);
  };
}, []);
```

### `getConnectedDevices(options: ConnectedDevicesOptions): Promise<BleDevice | BluetoothError>;`

Gets a list of connected devices.

| Parameter      | Type       | Description                                   | Default |
| -------------- | ---------- | --------------------------------------------- | ------- |
| `serviceUUIDs` | `string[]` | A list of service UUIDs for connected devices | `[]`    |

```tsx
const connectedDevices = Bluetooth.getConnectedDevices();
```

### `readFromDevice(options: ReadDeviceOptions): Promise<unknown | BluetoothError>`

Reads data from a device for a given characteristic. Returns the received data. The listener [`.read`](#-read) emits an event with the data when read.

| Parameter            | Type               | Description                                                                                              | Default                        |
| -------------------- | ------------------ | -------------------------------------------------------------------------------------------------------- | ------------------------------ |
| `peripheralUUID`     | `string`           | The UUID of the device to read from                                                                      | **Required**                   |
| `serviceUUID`        | `string`           | The UUID of the service that has the characteristic to read from                                         | **Required**                   |
| `characteristicUUID` | `string`           | The UUID of the characteristic to read from                                                              | **Required**                   |
| `dataType`           | `BufferDataTypes?` | The type of data expected. See [BufferDataTypes](#bufferdatatypes).                                      | `undefined` (returns `Buffer`) |
| `dataOffset`         | `number`           | The number of bytes to skip before starting to read.                                                     | `0`                            |
| `dataByteLength`     | `number`           | Number of bytes to read. This is for certain buffer types only, see [BufferDataTypes](#bufferdatatypes). | `0`                            |

```tsx
// ble
const readData = Bluetooth.readFromDevice({
  peripheralUUID: "xxx-xxx-xxx",
  serviceUUID: "yyy-yyy-yyy",
  characteristicUUID: "zzz-zzz-zzz"
}).then((data: Buffer) => {
  // returns a raw buffer. you'll need to use the Buffer package to decode (yarn add buffer)
  // Buffer.from(data).toString() // if your expected data is a string
});

// ble
// you can also provide the `data-` params to have the package automatically decode the Buffer data and return the decoded value
const readData = Bluetooth.readFromDevice({
  peripheralUUID: "xxx-xxx-xxx",
  serviceUUID: "yyy-yyy-yyy",
  characteristicUUID: "zzz-zzz-zzz",
  dataType: BufferDataTypes.BIGINT64_LE // bigint64 little endian
}).then((data: bigint) => console.log(data));

// listener (optional)
React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.read, readData =>
    console.log(readData)
  ); // this data will be in its raw format, so you will need to decode it with Buffer for BLE devices

  return () => {
    Bluetooth.removeListener(BluetoothTypes.read);
  };
}, []);
```

### `writeToDevice(options: WriteDeviceOptions): Promise<boolean | BluetoothError>`

Writes data to a device on a given characteristic. Returns a `boolean` for whether or not the data was successfully written to the device. The [`.write`](#-write) listener will emit an event when data is successfully written.

| Parameter            | Type      | Description                                                      | Default      |
| -------------------- | --------- | ---------------------------------------------------------------- | ------------ |
| `peripheralUUID`     | `string`  | The UUID of the device to read from                              | **Required** |
| `serviceUUID`        | `string`  | The UUID of the service that has the characteristic to read from | **Required** |
| `characteristicUUID` | `string`  | The UUID of the characteristic to read from                      | **Required** |
| `writeData`          | `string`  | The data to write.                                               | **Required** |
| `withResponse`       | `boolean` | Whether or not to write with response (vs. without).             | `true`       |

```tsx
// ble
const writeData = Bluetooth.writeToDevice({
  peripheralUUID: "xxx-xxx-xxx",
  serviceUUID: "yyy-yyy-yyy",
  characteristicUUID: "zzz-zzz-zzz",
  writeData: "aHVudGVyMgo="
});

// listener (optional)
React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.write, (dataDidWrite: boolean) =>
    console.log(dataDidWrite)
  );

  return () => {
    Bluetooth.removeListener(BluetoothEvents.write);
  };
}, []);
```

### `setCharacteristicNotify(options: SetNotifyOptions): Promise<void | BluetoothError>`

Sets whether or not to notify on a given characteristic. The listener [`.notification`](#-notification) emits an event when a notification is emitted from the device when `shouldNotify` is set to `true`.

| Parameter            | Type      | Description                                                      | Default      |
| -------------------- | --------- | ---------------------------------------------------------------- | ------------ |
| `peripheralUUID`     | `string`  | The UUID of the device to read from                              | **Required** |
| `serviceUUID`        | `string`  | The UUID of the service that has the characteristic to read from | **Required** |
| `characteristicUUID` | `string`  | The UUID of the characteristic to read from                      | **Required** |
| `shouldNotify`       | `boolean` | Whether or not to notify                                         | **Required** |

```tsx
React.useEffect(() => {
  Bluetooth.setCharacteristicNotify({
    peripheralUUID: "xxx-xxx-xxx",
    serviceUUID: "yyy-yyy-yyy",
    characteristicUUID: "zzz-zzz-zzz",
    shouldnotify: "true"
  });
}, []);

// listener
React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.notification, notification =>
    console.log(notification)
  );
}, []);
```

### `fetchServicesAndCharacteristics(options: FetchServicesCharacteristicsOptions): Promise<void | BluetoothError>`

Requests to fetch the services and their characteristics from a given device. This function returns nothing, instead the services and characteristics are emitted in 2 events: [`.discoverServices`](#-discoverServices) and [`.discoverCharacteristics`](#-discoverCharacteristics).

| Parameter        | Type     | Description                         | Default      |
| ---------------- | -------- | ----------------------------------- | ------------ |
| `peripheralUUID` | `string` | The UUID of the device to read from | **Required** |

```tsx
React.useEffect(() => {
  Bluetooth.fetchServicesAndCharacteristics({
    peripheralUUID: "xxx-xxx-xxx"
  });
}, []);

React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.discoverServices, discoveredServices =>
    console.log(discoveredServices)
  );

  Bluetooth.addListener(
    BluetoothEvents.discoverCharacteristics,
    discoveredCharacteristics => console.log(discoveredCharacteristics)
  );

  return () => {
    Bluetooth.removeListener(BluetoothEvents.discoverServices);
    Bluetooth.removeListener(BluetoothEvents.discoverCharacteristics);
  };
}, []);
```

### `fetchRSSI(options: Identifier): Promise<void | BluetoothError>`

Requests to fetch the RSSI of a given device. This function returns nothing, instead the RSSI is emitted on the [`.rssi`](#-rssi) event.

| Parameter        | Type     | Description                         | Default      |
| ---------------- | -------- | ----------------------------------- | ------------ |
| `peripheralUUID` | `string` | The UUID of the device to read from | **Required** |

```tsx
React.useEffect(() => {
  Bluetooth.fetchRSSI({
    peripheralUUID: "xxx-xxx-xxx"
  });
}, []);

React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.rssi, rssi => console.log(rssi));

  return () => {
    Bluetooth.removeListener(BluetoothEvents.rssi);
  };
}, []);
```

### `isDeviceConnected(options: Identifier): Promise<boolean | BluetoothError>`

Returns whether or not a given device is connected.

| Parameter        | Type     | Description                         | Default      |
| ---------------- | -------- | ----------------------------------- | ------------ |
| `peripheralUUID` | `string` | The UUID of the device to read from | **Required** |

```tsx
React.useEffect(() => {
  const isConnected = Bluetooth.isDeviceConnected({
    peripheralUUID: "xxx-xxx-xxx"
  });
}, []);
```

### `getDevice(options: Identifier): Promise<BleDevice | BluetoothError>`

Returns all device information for a given device by identifier.

| Parameter        | Type     | Description                         | Default      |
| ---------------- | -------- | ----------------------------------- | ------------ |
| `peripheralUUID` | `string` | The UUID of the device to read from | **Required** |

```tsx
React.useEffect(() => {
  const device = Bluetooth.isDeviceConnected({
    peripheralUUID: "xxx-xxx-xxx"
  });
}, []);
```

## Listeners

Most methods have a corresponding listener, and all listener events contain at least 3 key-value pairs.

```ts
type BluetoothEventData = {
  timestamp: "22 Oct 2021 14:23"; // time of event
  message: "some message"; // message describing the event
  device: BleDevice; // device object
};

type BleDevice = {
  uuid: string;
  name: string;
  servicesAndCharacteristics?: { [key: string]: string[] }[];
  state: DeviceConnectionStates;
  rssi?: number;
  ancsAuthorized?: boolean;
};
```

Some events will have extra keys if necessary.

Listeners can be added/removed with `ESP32.addListener` and `ESP32.removeListener`, respectfully. To get the event emitter itself, you can call `ESP32.eventEmitter`.

### `BluetoothEvent`

Potential emitted events from the listeners. Available as an enum (`BluetoothEvents`) or a string literal type.

| Name                                          | Listener                                                    |
| --------------------------------------------- | ----------------------------------------------------------- |
| `BluetoothDiscover`                           | [`.discover`](#-discover)                                   |
| `BluetoothStateChange`                        | [`.stateChange`](#-stateChange)                             |
| `BluetoothConnect`                            | [`.connect`](#-connect)                                     |
| `BluetoothConnectFail`                        | [`.connectFail`](#-connectFail)                             |
| `BluetoothDisconnect`                         | [`.disconnect`](#-disconnect)                               |
| `BluetoothConnectionEvent`                    | [`.connectionEvent`](#-connectionEvent)                     |
| `BluetoothRead`                               | [`.read`](#-read)                                           |
| `BluetoothWrite`                              | [`.read`](#-write)                                          |
| `BluetoothRSSI`                               | [`.rssi`](#-rssi)                                           |
| `BluetoothServicesModified`                   | [`.rssi`](#-servicesModified)                               |
| `BluetoothDiscoverServicesAndCharacteristics` | [`.discoverServices`](#-discoverServicesAndCharacteristics) |
| `BluetoothNotificationStateChange`            | [`.notificationStateChange`](#-notificationStateChange)     |
| `BluetoothDeviceNameChange`                   | [`.deviceNameChange`](#-deviceNameChange)                   |
| `BluetoothError`                              | All                                                         |

### `.stateChange`

Listens for Bluetooth state changes. In addition to the standard payload key-value pairs, this event will also emit a `state` key with one of `BluetoothState` as a value.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.stateChange,
    (data: BluetoothEventData) => console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

#### `BluetoothState`

Potential states the Bluetooth adapter can be in. Available as an enum (via `BluetoothStates`) or a string literal type.

| Name                      | Description                                                             |
| ------------------------- | ----------------------------------------------------------------------- |
| `permissionNotDetermined` | User has not been prompted to accept or deny Bluetooth permissions      |
| `permissionDenied`        | User has explicitly denied Bluetooth permission                         |
| `permissionRestricted`    | User's device does not allow Bluetooth usage                            |
| `permissionAllowedAlways` | User has granted Bluetooth permission to the app                        |
| `unauthorized`            | App isn't authorized to use Bluetooth                                   |
| `unavailable`             | Bluetooth is unavailable on the device                                  |
| `unknown`                 | Bluetooth adapter state isn't known                                     |
| `unsupported`             | Device does not support Bluetooth                                       |
| `resetting`               | Bluetooth connection was momentarily lost                               |
| `poweredOff`              | Bluetooth is powered off                                                |
| `poweredOn`               | Bluetooth is powered on                                                 |
| `ready`                   | Bluetooth is powered on and application has permission to use Bluetooth |

### `.discover`

Listens for devices during discovery. This listener will not listen for classic devices on iOS.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.discover, (data: BluetoothEventData) =>
    console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.connect`

Listens for device connections.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.connect, (data: BluetoothEventData) =>
    console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.connectFail`

Listens for device connection failures.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.connectFail,
    (data: BluetoothEventData) => console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.connectionEvent`

Listens for a classic device connection event (connected/disconnected).

```tsx
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.connectionEvent,
    (data: BluetoothEventData) => console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.disconnect`

Listens for device disconnection events.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.disconnect,
    (data: BluetoothEventData) => console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.read`

Listens for incoming characteristic data. This event will also emit a `readData` key with the raw read data.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.read, (data: BluetoothEventData) =>
    console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.write`

Listens for successfully written data. This event will also emit a `didWriteData` key with a boolean value.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.write, (data: BluetoothEventData) =>
    console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.rssi`

Listens for RSSI (signal strength) changes. This event will also emit an `rssi` key with the RSSI numeric value.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(BluetoothEvents.rssi, (data: BluetoothEventData) =>
    console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.servicesModified`

Listens for modified services on a device. This event will also emit an `invalidatedServices` key with a list of invalidated service UUIDs.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.servicesModified,
    (data: BluetoothEventData) => console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.discoverServicesAndCharacteristics`

Listens for discovered services and their characteristics on a device. This event will populate the `servicesAndCharacteristics` key on the `device` object. This value will look like this:

```json
{
  "servicesAndCharacteristics": {
    // where the key is the serviceUUID, and the value is an array of characteristic UUIDs for that service
    "yyy-yyy-yyyy": ["zzz-zzz-zzz", "aaa-aaa-aaa"],
    "mmm-mmm-mmm": ["nnn-nnn-nnn"]
  }
}
```

```tsx
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.discoverServicesAndCharacteristics,
    (data: BluetoothEventData) => console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.notificationStateChange`

Listens for when a characteristic's notification state changes (from `true` to `false` or vice versa). This event also emits a key `isNotifying` with a boolean value.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.notificationStateChange,
    (data: BluetoothEventData) => console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

### `.deviceNameChange`

Listens for when a device's name is changed. This event updates the `name` key value on the `device` object in the event.

```tsx
React.useEffect(() => {
  Bluetooth.addListener(
    BluetoothEvents.deviceNameChange,
    (data: BluetoothEventData) => console.log(data)
  );

  return () => {
    Bluetooth.removeListener();
  };
}, []);
```

## Acknowledgements

This library wouldn't exist without these open source libraries:

- [react-native-ble-manager](https://github.com/innoveit/react-native-ble-manager)
- [react-native-bluetooth-classic](https://github.com/kenjdavidson/react-native-bluetooth-classic)
