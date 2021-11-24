import Foundation
import CoreBluetooth

extension ESP32 {
  func getPermissionState() -> BluetoothStates {
    var stateString: BluetoothStates

    if #available(iOS 13.0, *) {
      switch cbManager.authorization {
      case .allowedAlways:
        stateString = .permissionAllowedAlways
      case .denied:
        stateString = .permissionDenied
      case .restricted:
        stateString = .permissionRestricted
      case .notDetermined:
        stateString = .permissionNotDetermined
      @unknown default:
        stateString = .unauthorized
      }
    } else {
      stateString = .unauthorized
    }

    return stateString
  }

  func getBluetoothState() -> BluetoothStates {
    var stateString: BluetoothStates

    switch cbManager.state {
    case .unauthorized:
      stateString = getPermissionState()
    case .unknown:
      stateString = .unknown
    case .unsupported:
      stateString = .unsupported
    case .resetting:
      stateString = .resetting
    case .poweredOff:
      stateString = .poweredOff
    case .poweredOn:
      stateString = .poweredOn
    @unknown default:
      stateString = .unknown
    }

    return stateString
  }

  func rejectOnBluetoothError(rejecter reject: RCTPromiseRejectBlock) {
    let stateString: BluetoothStates = self.getBluetoothState()

    var err: BluetoothErrors = .bluetoothUnknown

    if stateString == .permissionDenied {
      err = .permissionDenied
    } else if stateString == .permissionRestricted {
      err = .permissionRestricted
    } else if stateString == .permissionNotDetermined {
      err = .permissionNotDetermined
    } else if stateString == .unauthorized {
      err = .unauthorized
    }

    self.throwError(err, rejecter: reject)
  }

  func isBluetoothReady() -> Bool {
    let state: BluetoothStates = self.getBluetoothState()

    if state == .poweredOn {
      return true
    }

    return false
  }
}
