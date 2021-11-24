const {
  createRunOncePlugin,
  withInfoPlist,
  withEntitlementsPlist,
  withAndroidManifest
} = require("@expo/config-plugins");
const pkg = require("../package.json");

const LOCATION_PERMISSION =
  "Allow $(PRODUCT_NAME) to use location to find nearby WiFi networks";
const LOCAL_NETWORK_PERMISION =
  "Allow $(PRODUCT_NAME) to use the local network to discover devices on your WiFi network";

const withIos = (
  config,
  {
    locationWhenInUsePermissionDescription,
    locationAlwaysPermissionDescription,
    localNetworkPermissionDescription
  }
) => {
  config = withInfoPlist(c, config => {
    let {
      NSLocationWhenInUseUsageDescription,
      NSLocationAlwaysAndWhenInUseUsageDescription,
      NSLocalNetworkUsageDescription
    } = config.modResults;

    NSLocationAlwaysAndWhenInUseUsageDescription = locationAlwaysPermissionDescription
      ? locationAlwaysPermissionDescription
      : LOCATION_PERMISSION;
    NSLocationWhenInUseUsageDescription = locationWhenInUsePermissionDescription
      ? locationWhenInUsePermissionDescription
      : LOCATION_PERMISSION;
    NSLocalNetworkUsageDescription = localNetworkPermissionDescription
      ? localNetworkPermissionDescription
      : LOCAL_NETWORK_PERMISION;

    return config;
  });

  config = withEntitlementsPlist(c, config => {
    config.modResults["com.apple.developer.networking.wifi-info"] = true;
    config.modResults[
      "com.apple.developer.networking.HotspotConfiguration"
    ] = true;
    config.modResults[
      "com.apple.external-accessory.wireless-configuration"
    ] = true;

    return config;
  });

  return config;
};

const getManifestItem = (manifest, permission, isSDK23) => {
  const uses = isSDK23 ? "uses-permission-sdk-23" : "uses-permission";

  if (
    !manifest[uses].find(
      item => item.$["android.name"] === `android.permission.${permission}`
    )
  ) {
    manifest[uses]?.push({
      $: {
        "android.name": `android.permission.${permission}`
      }
    });
  }
};

const withAndroid = (config, {}) => {
  return withAndroidManifest(c, config => {
    const { manifest } = config.modResults;

    if (!Array.isArray(manifest["uses-permission"])) {
      manifest["uses-permission"] = [];
    }

    if (!Array.isArray(manifest["uses-permission-sdk-23"])) {
      manifest["uses-permission-sdk-23"] = [];
    }

    const permissions = [
      "INTERNET",
      "CHANGE_WIFI_STATE",
      "ACCESS_WIFI_STATE",
      "CHANGE_NETWORK_STATE",
      "ACCESS_NETWORK_STATE"
    ];

    permissions.forEach(permission =>
      getManifestItem(manifest, permission, false)
    );
    permissions.forEach(permission =>
      getManifestItem(manifest, permission, true)
    );

    return config;
  });
};

const withWifi = (config, props = {}) => {
  const _props = props || {};

  config = withIos(config, _props);
  config = withAndroid(config, _props);

  return config;
};

module.exports = createRunOncePlugin(withWifi, pkg.name, pkg.version);
