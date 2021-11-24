import Foundation
import CoreBluetooth

extension ESP32 {
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    var status: Int?

    switch peripheral.state {
    case .poweredOn:
      _ = checkPermissions()
    case .unauthorized:
      status = //d enied
    case .unknown:
      status = // unknown
    default:
      status // not determined
    }
  }
}
