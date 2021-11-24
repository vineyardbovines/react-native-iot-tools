//
//  ESP32Errors.swift
//  ESP32
//
//  Created by Sara Pope on 10/19/21.
//

import Foundation

enum ESP32Errors: Error {
  // generic - 100
  case unauthorized
  case notPermittedForType
  case noDeviceProvided
  // bluetooth - 200
  case bluetoothDisabled
  case bluetoothUnknown
  case bluetoothUnsupported
  // permission - 300
  case permissionDenied
  case permissionRestricted
  case permissionNotDetermined
  // device - 400
  case invalidUUID
  case deviceNotFound
  case deviceNotConnected
  case couldNotConnect
  case couldNotDisconnect
  // data - 600
  case malformedData

  var info: (code: Int, abbr: String, message: String) {
    switch self {
    case .unauthorized:
      return (
        100,
        "unauthorized",
        "Bluetooth not authorized, check permissions"
      )
    case .notPermittedForType:
      return (
        110,
        "not_permitted_for_type",
        "Function isn't valid for type."
      )
    case .noDeviceProvided:
      return (
        120,
        "no_device_provided",
        "No device provided. Must provide deviceUUID for BLE or serialNumber for classic (serial)."
      )
    case .bluetoothUnknown:
      return (
        200,
        "bluetooth_unknown",
        "Bluetooth in unknown or resetting state"
      )
    case .bluetoothDisabled:
      return (
        210,
        "bluetooth_disabled",
        "Bluetooth not enabled"
      )
    case .bluetoothUnsupported:
      return (
        220,
        "bluetooth_unsupported",
        "Bluetooth not supported on this device"
      )
    case .permissionDenied:
      return (
        300,
        "permission_denied",
        "Bluetooth permission denied by user"
      )
    case .permissionRestricted:
      return (
        310,
        "permission_restricted",
        "Bluetooth permission restricted on this device"
      )
    case .permissionNotDetermined:
      return (
        320,
        "permission_denied",
        "Bluetooth permission cannot be determined"
      )
    case .deviceNotFound:
      return (
        400,
        "device_not_found",
        "Device not found, ensure that it's connected and the UUID is correct"
      )
    case .deviceNotConnected:
      return (
        410,
        "device_not_connected",
        "Device is not connected"
      )
    case .couldNotConnect:
      return (
        420,
        "could_not_connect",
        "Could not connect to device"
      )
    case .couldNotDisconnect:
      return (
        430,
        "could_not_disconnect",
        "Could not disconnect from device"
      )
    case .invalidUUID:
      return (
        430,
        "invalid_uuid",
        "Invalid UUID"
      )
    case .malformedData:
      return (
        600,
        "invalid_write_data",
        "Invalid write data- must be base64 string encoded Buffer"
      )
  }

  var error: NSError {
    return NSError(domain: "gretzky.rniot.esp32", code: self.info.code, userInfo: ["error": self.info.message])
  }
}
