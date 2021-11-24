import Foundation

enum WifiErrors: Error {
  case unknown
  case unavailable
  case pending
  case systemError
  case internalError
  case appNotInForeground
  case locationServicesDisabled
  case locationPermissionDenied
  case locationPermissionRestricted
  case invalid
  case invalidSSID
  case invalidSSIDPrefix
  case invalidSettings
  case ssidNotFound
  case prefixRequiresPassphrase
  case invalidPassphrase
  case userDenied
  case networkNotFound
  case couldNotConnect
  case couldNotDisconnect
  case alreadyAssociated
  case notAvailableForVersion
  case requiresEAPSettings

  var info(code: Int, abbr: String, message: String) {
    switch self {
    case .unknown:
      return (
        100,
        "unknown",
        "Wifi service unknown or initializing"
      )
    case .unavailable:
      return (
        110,
        "unavailable",
        "Not available for this iOS version"
      )
    case .pending:
      return (
        120,
        "pending",
        "Configuration pending"
      )
    case .systemError:
      return (
        130,
        "system_error",
        "iOS system error occurred"
      )
    case .internalError:
      return (
        140,
        "internal_error",
        "Internal configuration error occurred"
      )
    case .appNotInForeground:
      return (
        150,
        "app_not_in_foreground",
        "Cannot configure when application is not in foreground"
      )
    case .notAvailableForVersion:
      return (
        160,
        "not_available_for_version",
        "Method not available on iOS version"
      )
    case .locationServicesDisabled:
      return (
        200,
        "location_services_disabled",
        "Location services are disabled"
      )
    case .locationPermissionDenied:
      return (
        210,
        "location_permission_denied",
        "Location permission was denied"
      )
    case .locationPermissionRestricted:
      return (
        220,
        "location_permission_restricted",
        "Location permission is restricted"
      )
    case .invalid:
      return (
        300,
        "invalid",
        "Invalid parameters"
      )
    case .invalidSSID:
      return (
        310,
        "invalid_ssid",
        "Invalid SSID"
      )
    case .invalidSSIDPrefix:
      return (
        320,
        "invalid_ssid_prefix",
        "Invalid SSID prefix"
      )
    case .ssidNotFound:
      return (
        330,
        "ssid_not_found",
        "SSID not found"
      )
    case .invalidSettings:
      return (
        340,
        "invalid_settings",
        "Invalid configuration settings. This could be EAP or HS20."
      )
    case .prefixRequiresPassphrase:
      return (
        340,
        "prefix_requires_passphrase",
        "Connecting to an SSID prefix requires a passphrase"
      )
    case .invalidPassphrase:
      return (
        400,
        "invalid_passphrase",
        "Invalid passphrase"
      )
    case .userDenied:
      return (
        500,
        "user_denied",
        "User denied from connecting"
      )
    case .networkNotFound:
      return (
        600,
        "network_not_found",
        "Network not found"
      )
    case .couldNotConnect:
      return (
        700,
        "could_not_connect",
        "Could not connect to network"
      )
    case .couldNotDisconnect:
      return (
        710,
        "could_not_disconnect",
        "Could not disconnect from network"
      )
    case .alreadyAssociated:
      return (
        730,
        "already_associated",
        "Network is already configured and connected to"
      )
    case .requiresEAPSettings:
      return (
        800,
        "requires_eap_settings",
        "HS20 configuration also requires EAP settings"
      )
    }
  }

  var error: NSError {
    return NSError(domain: "gretzky.react-native-iot-tools.wifi", code: self.info.code, userInfo: ["error": self.info.message])
  }
}
