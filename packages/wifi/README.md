# @react-native-iot-tools/wifi

React Native module for connecting to Wifi networks. **Currently iOS only.**

| Platform | SDK                                                                                                      | Minimum version requirement |
| -------- | -------------------------------------------------------------------------------------------------------- | --------------------------- |
| iOS      | [NEHotspotConfiguration](https://developer.apple.com/documentation/networkextension/wi-fi_configuration) | 12.0                        |

## Getting Started

If you're using Expo (SDK 42 or above), [click here](#using-expo-).

Otherwise, install the library using Yarn or npm:

```bash
yarn add @react-native-iot-tools/wifi
// or
npm install @react-native-iot-tools/wifi --save
```

### Using React Native >= 0.60

The package will be linked automatically (see [autolinking](https://github.com/react-native-community/cli/blob/master/docs/autolinking.md)). Linking manually is not required.

- **iOS**:

  `npx pod-install` # Install CocoaPods (required)

  Add one of the permission strings below in your `Info.plist` (depending on your application usage). If you only need the location permission for WiFi purposes, you can use `WhenInUsage`.

  ```plist
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>YOUR TEXT</string>
  ```

  **IMPORTANT**

  In order to use this library your app will require certain entitlements, and these entitlements require that your app be signed by a **paid** Apple developer account.

  In Xcode > Signing and Capabilities > press "+ Capability" and add the following:

  - Access WiFi Information
  - Hotspot Configuration
  - Wireless Accessory Configuration

  Xcode will handle the rest.

  If you do not see all 3 of these entitlements in the add capability window, it means your app is not signed by a paid developer account. In signing, change 'Team' to a paid account.

### Using React Native < 0.60

You then need to link the native parts of the library for the platforms you are using. The easiest way to link the library is using the CLI tool by running this command from the root of your project:

```bash
react-native link @react-native-iot-tools/wifi
```

If you can't or don't want to use the CLI tool, you can also manually link the library using the instructions below (click on the arrow to show them):

<details>
<summary>Manually link the library on iOS</summary>

Either follow the [instructions in the React Native documentation](https://facebook.github.io/react-native/docs/linking-libraries-ios#manual-linking) to manually link the framework or link using [Cocoapods](https://cocoapods.org) by adding this to your `Podfile`:

```ruby
pod 'wifi', :path => '../node_modules/react-native-iot-tools/packages/wifi'
```

Make the following changes:

#### `Info.plist`

Add one of the permission strings below in your `Info.plist` (depending on your application usage). If you only need the location permission for WiFi purposes, you can use `WhenInUsage`.

```plist
<key>NSLocationWhenInUseUsageDescription</key>
<string>YOUR TEXT</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>YOUR TEXT</string>
```

##### Entitlements

In order to use this library your app will require certain entitlements, and these entitlements require that your app be signed by a **paid** Apple developer account.

In Xcode > Signing and Capabilities > press "+ Capability" and add the following:

- Access WiFi Information
- Hotspot Configuration
- Wireless Accessory Configuration

Xcode will handle the rest.

If you do not see all 3 of these entitlements in the add capability window, it means your app is not signed by a paid developer account. In signing, change 'Team' to a paid account.

</details>

### Using Expo (SDK >=42)

Install the library

```bash
expo install @react-native-iot-tools/wifi
```

Add the config plugin to the plugins array of your `app.json` or `app.config.js`

```
{
  "expo": {
    "plugins": ["@react-native-iot-tools/wifi/with-wifi-expo-plugin"]
  }
}
```

The plugin provides props for customization. Every time you change the props, you'll need to rebuild (and `prebuild`) the native app.

| Prop                                   | Description                                                                                                                                                                                       |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `modes`                                | Adds [`UIBackgroundModes`](https://developer.apple.com/documentation/bundleresources/information_property_list/uibackgroundmodes) to `Info.plist`                                                 |
| `locationWhenInUseDescription`         | Sets the [`NSLocationWhenInUseDescription`](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationwheninusepermission) in `Info.plist`                    |
| `locationAlwaysAndWhenInUsePermission` | Sets the [`NSLocationAlwaysAndWhenInUseDescription`](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationalwaysandwheninusedescription) in `Info.plist` |

**Example**

```json
{
  "expo": {
    "plugins": [
      [
        "react-native-iot-tools/wifi/with-wifi-expo-plugin",
        {
          "isBackgroundEnabled": true,
          "modes": ["peripheral", "central", "external-accessory"],
          "locationWhenInUsePermission": "Allow $(PRODUCT_NAME) to use location in order to find nearby WiFi networks",
          "locationAlwaysAndWhenInUsePermission": "Allow $(PRODUCT_NAME) to use location in order to find nearby WiFi networks"
        }
      ]
    ]
  }
}
```

## Methods

### `requestLocationPermission(options?: RequestLocationOptions): Promise<void>`

Requests location permission if the user hasn't been prompted for it. The [`.locationPermissionChange](#-locationPermissionChange) listener will emit an event when the user changes location permissions for your app.

| Parameter | Type                      | Description                                                        | Default      |
| --------- | ------------------------- | ------------------------------------------------------------------ | ------------ |
| type      | `LocationPermissionTypes` | The type of location permission to request (always or when in use) | `.whenInUse` |

```tsx
const requestLocationPermission = await Wifi.requestLocationPermission({
  type: LocationPermissionTypes.always
});
```

### `connectToNetwork(options: ConnectOptions): Promise<string>`

Connects to a given network. Returns the SSID of the connected network. The [`.connect`](#-connect) listener will emit an event when a network connects (optional).

| Parameter    | Type           | Description                                | Default      |
| ------------ | -------------- | ------------------------------------------ | ------------ |
| ssid         | `string`       | The SSID to connect to                     | **Required** |
| passphrase   | `string`       | The SSID passphrase (if protected network) | `""`         |
| isWEP        | `boolean`      | Whether or not the network uses WEP        | `false`      |
| ssidPrefix   | `string`       | SSID prefix to connect to                  | `null`       |
| eapSettings  | `EAPSettings`  | EAP settings to pass to the hotspot        | `null`       |
| hs20Settings | `HS20Settings` | HS20 settings to pass to the hotspot       | `null`       |

```tsx
const connectToNetwork = await Wifi.connectToNetwork({
  ssid: "Pretty Fly for a WiFi"
});

const connectToProtectedNetwork = await Wifi.connectToNetwork({
  ssid: "Bill Gates 5G COVID Spreader",
  password: "hunter2"
});
```

### `disconnectFromNetwork(options: DisconnectOptions): Promise<boolean>`

Disconnects from a given network. Returns `true` if successfully disconnected. The [`.disconnect`](#-disconnect) listener will emit an event when a network disconnects (optional).

| Parameter | Type     | Description            | Default      |
| --------- | -------- | ---------------------- | ------------ |
| ssid      | `string` | The SSID to connect to | **Required** |

```tsx
const disconnect = await Wifi.disconnectFromNetwork({
  ssid: "Bill Gates 5G COVID Spreader"
});
```

### `getCurrentNetwork(): Promise<string>`

Returns the currently connected network's SSID.

```tsx
const connectedNetwork = await Wifi.getConnectedNetwork();
```

### `getConfiguredNetworks(): Promise<string[]>`

Gets a list of known (previously connected) networks' SSIDs.

```tsx
const knownNetworks = Wifi.getConfiguredNetworks();
```

### `isConnectedToNetwork(options: IsConnectedOptions): Promise<boolean>`

Returns whether or not the passed SSID is the currently connected network.

| Parameter | Type     | Description                        | Default      |
| --------- | -------- | ---------------------------------- | ------------ |
| ssid      | `string` | The SSID to check for connectivity | **Required** |

```tsx
const isConnected = Wifi.isConnectedToNetwork({
  ssid: "Bill Gates 5G COVID Spreader"
});
```

## Listeners

Some methods have a corresponding listeners, and all listeners contain at least 2 key-value pairs.

```tsx
type WifiEventData = {
  timestamp: "22 Oct 2021 14:23"; // time of event
  message: "some message"; // message describing the event
};
```

Some events will have extra keys if necessary.

Listeners can be added/removed with `Wifi.addListener` and `Wifi.removeListener`, respectfully. To get the event emitter itself, you can call `Wifi.eventEmitter`.

### `WifiEvent`

Potential emitted events from the listeners. Available as an enum (`WifiEvents`) or a string literal type.

| Name               | Listener                          |
| ------------------ | --------------------------------- |
| `WifiConnected`    | [`.connected`](#-connected)       |
| `WifiDisconnected` | [`.disconnected`](#-disconnected) |

### `.connected`

Listens for wifi connection events.

```tsx
React.useEffect(() => {
  Wifi.addListener(WifiEvents.connected, (eventPayload: WifiEventData) =>
    console.log(eventPayload)
  );

  return () => {
    Wifi.removeListener();
  };
}, []);
```

### `.disconnected`

Listens for wifi disconnection events.

```tsx
React.useEffect(() => {
  Wifi.addListener(WifiEvents.disconnected, (eventPayload: WifiEventData) =>
    console.log(eventPayload)
  );

  return () => {
    Wifi.removeListener();
  };
}, []);
```
