//
//  BluetoothHelpers.swift
//  Bluetooth
//
//  Created by Sara Pope on 10/19/21.
//

import Foundation
import CoreBluetooth
import ExternalAccessory

extension Bluetooth {
  func throwError(_ error: BluetoothErrors, rejecter reject: RCTPromiseRejectBlock, logOnly: Bool = false) {
    if logOnly {
      NSLog("%@: %@", error.info.message, error.error)
    } else {
      reject(error.info.abbr, error.info.message, error.error)
    }
  }

  func dispatchQueue(delay: TimeInterval?, closure: @escaping () -> Void) {
    if delay == nil {
      DispatchQueue.main.async {
        closure()
      }
    } else {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay!) {
        closure()
      }
    }
  }

  func fireEvent(
    withName: BluetoothEvents,
    device: CBPeripheral?,
    message: String? = nil,
    dataKey: String? = nil,
    data: Any? = nil,
    delay: TimeInterval?
  ) {
    let dateFormatter = DateFormatter()

    dateFormatter.dateFormat = "d MMM y HH:mm:ss"

    var eventBody: [String: Any] = [
      "timestamp": dateFormatter.string(from: Date()),
      "message": message ?? withName.message
    ]

    if device != nil {
      eventBody["device"] = device.asDictionary()
    }

    if dataKey != nil && data != nil {
      eventBody[dataKey!] = data
    }

    self.dispatchQueue(delay: delay) {
      self.sendEvent(withName: withName.rawValue, body: eventBody)
    }
  }
}
