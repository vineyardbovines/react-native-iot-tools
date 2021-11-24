import Foundation

enum BluetoothStates: String {
  case permissionAllowedAlways
  case permissionDenied
  case permissionRestricted
  case permissionNotDetermined
  case unauthorized
  case unknown
  case unsupported
  case resetting
  case poweredOff
  case poweredOn
}
