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
  func handleServiceUUIDs(_ serviceUUIDStrings: [String]) -> [CBUUID] {
    if savedServiceUUIDs.count > 0 {
      savedServiceUUIDs = []
    }

    let serviceUUIDs = serviceUUIDStrings
      .map { $0.toCBUUID() }
      .compactMap { $0 }

    savedServiceUUIDs = serviceUUIDs

    return serviceUUIDs
  }

  func removeCallback(_ callbacks: NSMutableDictionary, forDevice peripheral: CBPeripheral, message: String) {
    for key in callbacks.allKeys {
      if (key as AnyObject).hasPrefix(peripheral.uuid) {
        let callback: RCTPromiseResolveBlock = callbacks.object(forKey: key) as! RCTPromiseResolveBlock

        callback([String(format: message, peripheral.uuid)])
        callbacks.removeObject(forKey: key)
      }
    }
  }

  func withDevice(
    _ options: NSDictionary,
    shouldBeConnected: Bool,
    completion: @escaping (_ device: CBPeriphral) -> Void
  ) {
    guard isBluetoothReady() else {
      rejectOnBluetoothError(rejecter: reject)
      return
    }

    guard let peripheralUUID = UUID(uuidString: options["peripheralUUID"]) else {
      throwError(.invalidUUID, rejecter: reject)
      return nil
    }

    guard let peripheral = cbManager.retrievePeripherals(
      withIdentifiers: [peripheralUUID]
    ).first(where: { $0.uuid == options["peripheralUUID"] }) {
      throwError(.deviceNotFound, rejecter: reject)
      return
    }

    if shouldBeConnected && peripheral.state != .connected {
      throwError(.deviceNotConnected, rejecter: reject)
      return
    }

    completion(peripheral)
  }
}
