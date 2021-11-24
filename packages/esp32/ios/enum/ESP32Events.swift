import Foundation

enum ESP32Events: String, CaseIterable {
  discoverDevices,
  discoverWifiNetworks,
  connect,
  disconnect,
  connectFail,
  provision

  static func asArray() -> [String] {
    var events: [String] = [String]()

    for event in ESP32Events.allCases {
      events.append(event.rawValue)
    }

    return events
  }

  var message: String {
    switch self
    case .requestEnableBt:
      return "Requesting Bluetooth enable"
    case .discoverDevices:
      return "Discovered devices over Bluetooth"
    case .discoverWifiNetworks:
      return "Discovered Wifi networks"
    case .connectionEvent:
      return "Device connection event"
    case .provision:
      return "Provisioned device"
  }
}
