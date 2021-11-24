//
//  BluetoothEvents.swift
//  Bluetooth
//
//  Created by Sara Pope on 10/19/21.
//

import Foundation

enum BluetoothEvents: String, CaseIterable {
  case discover = "BluetoothDiscover"
  case stateChange = "BluetoothStateChange"
  case connect = "BluetoothConnect"
  case disconnect = "BluetoothDisconnect"
  case connectFail = "BluetoothConnectFail"
  case connectionEvent = "BluetoothConnectionEvent"
  case read = "BluetoothRead"
  case write = "BluetoothWrite"
  case error = "BluetoothError"
  case rssi = "BluetoothRSSI"
  case servicesModified = "BluetoothServicesModified"
  case discoverServices = "BluetoothDiscoverServices"
  case discoverCharacteristics = "BluetoothDiscoverCharacteristics"
  case notificationStateChange = "BluetoothNotificationStateChange"
  case deviceNameChange = "BluetoothDeviceNameChange"

  static func asArray() -> [String] {
    var events: [String] = [String]()

    for event in BluetoothEvents.allCases {
      events.append(event.rawValue)
    }

    return events
  }

  var message: String {
    switch self {
    case .discover:
      return "Discovered device"
    case .stateChange:
      return "Bluetooth state change"
    case .connect:
      return "Connected to device"
    case .connectFail:
      return "Failed to connect to device"
    case .disconnect:
      return "Disconnected from device"
    case .read:
      return "Read from device"
    case .write:
      return "Write to device"
    case .connectionEvent:
      return "Peer connection event"
    case .rssi:
      return "Device RSSI"
    case .servicesModified:
      return "Services invalidated"
    case .discoverServices:
      return "Services discovered"
    case .discoverCharacteristics:
      return "Characteristics discovered"
    case .notificationStateChange:
      return "Notification state change"
    case .deviceNameChange:
      return "Device name change"
    case .error:
      return "An error occurred"
    }
  }
}
