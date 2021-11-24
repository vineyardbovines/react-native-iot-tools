//
//  String+Extensions.swift
//  Bluetooth
//
//  Created by Sara Pope on 10/19/21.
//

import Foundation
import CoreBluetooth

extension String {
  func toCBUUID() -> CBUUID? {
    let uuid: String
    switch self.count {
    case 4:
      uuid = "0000\(self)-0000-1000-8000-00805f9b34fb"
    case 8:
      uuid = "\(self)-0000-1000-8000-00805f9b34fb"
    default:
      uuid = self
    }
    guard let nsuuid = UUID(uuidString: uuid) else {
      return nil
    }
    return CBUUID(nsuuid: nsuuid)
  }

  var fromBase64: Data? {
    return Data(base64Encoded: self, options: .ignoreUnknownCharacters)
  }
}
