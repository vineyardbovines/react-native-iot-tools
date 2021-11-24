//
//  Bluetooth+CBPeripheralDelegate.swift
//  Bluetooth
//
//  Created by Sara Pope on 10/19/21.
//

import Foundation
import CoreBluetooth

extension Bluetooth: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if error != nil {
      self.fireEvent(
        withName: .discoverServices,
        device: peripheral.asDictionary(),
        message: "Failed to discover services",
        dataKey: "error",
        data: error,
        delay: nil
      )
      return
    } else if let services = peripheral.services as [CBService]? {
      for service in services {
        peripheral.discoverIncludedServices(nil, for: service)
        peripheral.discoverCharacteristics(nil, for: service)
      }

      self.fireEvent(
        withName: .discoverServices,
        device: peripheral.asDictionary(),
        delay: nil
      )
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
    peripheral.discoverCharacteristics(nil, for: service)
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if error != nil {
      self.fireEvent(
        withName: .discoverCharacteristics,
        device: peripheral.asDictionary(),
        message: "Failed to discover characteristics",
        dataKey: "error",
        data: error,
        delay: nil
      )
      return
    }

    self.fireEvent(
      withName: .discoverCharacteristics,
      device: peripheral.asDictionary(),
      dataKey: "forService",
      data: service.uuid.uuidString,
      delay: nil
    )
  }

  func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    self.fireEvent(
      withName: .servicesModified,
      device: peripheral.asDictionary(),
      dataKey: "invalidatedServices",
      data: invalidatedServices.map { $0.uuid.uuidString },
      delay: nil
    )
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    let key = String(format: "%@|%@", peripheral.uuid, characteristic.uuid.uuidString)

    let readCallback: RCTPromiseResolveBlock = readCallbacks.object(forKey: key) as! RCTPromiseResolveBlock

    if error != nil {
      self.fireEvent(
        withName: .read,
        device: peripheral.asDictionary(),
        message: "Failed to read from device",
        dataKey: "error",
        data: error,
        delay: nil
      )

      readCallback(NSNull())
      readCallbacks.removeObject(forKey: key)

      return
    }

    let result = characteristic.value?.withUnsafeBytes { bytes in
      return bytes
    }

    readCallback(result)
    readCallbacks.removeObject(forKey: key)

    self.fireEvent(
      withName: .read,
      device: peripheral.asDictionary(),
      dataKey: "data",
      data: result,
      delay: nil
    )
  }

  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    let key = String(format: "%@|%@", peripheral.uuid, characteristic.uuid.uuidString)

    let writeCallback: RCTPromiseResolveBlock = writeCallbacks.object(forKey: key) as! RCTPromiseResolveBlock

    if error != nil {
      self.fireEvent(
        withName: .write,
        device: peripheral.asDictionary(),
        message: "Failed to write to device",
        dataKey: "error",
        data: error,
        delay: nil
      )

      writeCallback(NSNull())
      writeCallbacks.removeObject(forKey: key)
      return
    }

    writeCallback(true)
    writeCallbacks.removeObject(forKey: key)

    self.fireEvent(
      withName: .write,
      device: peripheral.asDictionary(),
      dataKey: "didWrite",
      data: true,
      delay: nil
    )
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    if error != nil {
      self.fireEvent(
        withName: .notificationStateChange,
        device: peripheral.asDictionary(),
        message: "Failed to get notification state",
        dataKey: "error",
        data: error,
        delay: nil
      )
      return
    }

    self.fireEvent(
      withName: .notificationStateChange,
      device: peripheral.asDictionary(),
      dataKey: "characteristic",
      data: characteristic.uuid.uuidString,
      delay: nil
    )
  }

  func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    if error != nil {
      self.fireEvent(
        withName: .rssi,
        device: peripheral.asDictionary(),
        message: "Failed to read RSSI",
        dataKey: "error",
        data: error,
        delay: nil
      )
      return
    }

    self.fireEvent(
      withName: .rssi,
      device: peripheral.asDictionary(),
      dataKey: "rssi",
      data: RSSI,
      delay: nil
    )
  }

  func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
    self.fireEvent(
      withName: .deviceNameChange,
      device: peripheral.asDictionary(),
      delay: nil
    )
  }
}
