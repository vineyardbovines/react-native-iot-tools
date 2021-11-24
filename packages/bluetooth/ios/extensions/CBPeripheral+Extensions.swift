//
//  CBPeripheral+Extensions.swift
//  Bluetooth
//
//  Created by Sara Pope on 10/20/21.
//

import Foundation
import CoreBluetooth

extension CBPeripheral {
  var uuid: String {
    return self.identifier.uuidString
  }

  func asDictionary(rssi: NSNumber? = nil) -> NSMutableDictionary {
    let dict = NSMutableDictionary()

    dict.setValue(self.uuid, forKey: "uuid")
    dict.setValue(self.name ?? "", forKey: "name")

    let servicesAndCharacteristics = NSMutableDictionary()

    let services = self.services ?? []

    guard services.count > 0 else {
      dict.setValue([], forKey: "servicesAndCharacteristics")
      return dict
    }

    for service in services {
      servicesAndCharacteristics[service.uuid.uuidString] = service.characteristics?.map { $0.uuid.uuidString }
    }

    dict.setValue(servicesAndCharacteristics, forKey: "servicesAndCharacteristics")
    dict.setValue(self.state, forKey: "connectionState")

    if rssi != nil {
      dict.setValue(rssi, forKey: "rssi")
    }

    if #available(iOS 13.0, *) {
      dict.setValue(self.ancsAuthorized, forKey: "ancsAuthorized")
    }

    return dict
  }

  func characteristicByUUID(
    _ characteristicUUIDString: String!,
    forService serviceUUIDString: String!
  ) -> (CBCharacteristic, String)? {
    let services = self.services ?? []

    guard let service = services.first(where: { $0.uuid.uuidString == serviceUUIDString }) else {
      return nil
    }

    let characteristics = service.characteristics ?? []

    guard let characteristic = characteristics.first(where: { $0.uuid.uuidString == characteristicUUIDString }) else {
      return nil
    }

    let key = String(format: "%@|%@", self.identifier.uuidString, characteristic.uuid.uuidString)

    return (characteristic, key)
  }

  var isConnected: Bool {
    return self.state == .connected
  }

  func getConnectionOptions(_ options: NSDictionary?) -> [String: Any] {
    var connectionOptions = [String: Any]()

    if let notifyOnConnect = options?["notifyOnConnect"] as? Bool {
      connectionOptions[CBConnectPeripheralOptionNotifyOnConnectionKey] = NSNumber(booleanLiteral: notifyOnConnect)
    }

    if let notifyOnDisconnect = options?["notifyOnDisconnect"] as? Bool {
      connectionOptions[CBConnectPeripheralOptionNotifyOnDisconnectionKey] = NSNumber(booleanLiteral: notifyOnDisconnect)
    }

    if let notifyOnNotification = options?["notifyOnNotification"] as? Bool {
      connectionOptions[CBConnectPeripheralOptionNotifyOnNotificationKey] = NSNumber(booleanLiteral: notifyOnNotification)
    }

    if #available(iOS 13.0, *) {
      if let requireANCS = options?["requireANCS"] as? Bool {
        connectionOptions[CBConnectPeripheralOptionRequiresANCS] = NSNumber(booleanLiteral: requireANCS)
      }

      if let startDelay = options?["startDelay"] as? NSNumber {
        connectionOptions[CBConnectPeripheralOptionNotifyOnNotificationKey] = startDelay
      }
    }

    return connectionOptions
  }

  func readFromDevice(_ characteristicUUIDString: String!, forService serviceUUIDString: String!) -> String? {
    guard let (characteristic, key) = self.characteristicByUUID(
      characteristicUUIDString,
      forService: serviceUUIDString
    ) else {
      throwError(.characteristicNotFound, rejecter: reject)
      return nil
    }

    self.readValue(for: characteristic)

    return key
  }

  func writeToDevice(
    _ characteristicUUIDString: String!,
    forService serviceUUIDString: String!,
    withResponse: Bool!, writeData: String!
  ) -> String? {
    guard let (characteristic, key) = self.characteristicByUUID(
      characteristicUUIDString,
      forService: serviceUUIDString
    ) else {
      throwError(.characteristicNotFound, rejecter: reject)
      return nil
    }

    if withResponse == false && self.canSendWriteWithoutResponse == false {
      NSLog("Peripheral $@ cannot send write without response. Falling back.", self.uuid)
    }

    let writeType: CBCharacteristicWriteType = self.canSendWriteWithoutResponse == false || withResponse == true
      ? .withResponse
      : .withoutResponse

    guard let value = writeData.fromBase64 else {
      throwError(.invalidWriteData, rejecter: reject)
      return nil
    }

    let maxPacketSize = self.maximumWriteValueLength(for: writeType)

    // TODO: evaluate
    if value.count > maxPacketSize {
      var offset = 0
      var writtenSize = 0

      repeat {
        let packetSize = min(value.count - offset, maxPacketSize)
        let packet = value.subdata(in: offset..<offset+packetSize)

        self.writeValue(packet, for: characteristic, type: writeType)

        writtenSize += packetSize

        if writtenSize >= value.count {
          break
        }

        offset += packetSize
      } while offset < value.count
    } else {
      self.writeValue(value, for: characteristic, type: writeType)
    }

    return key
  }

  func setNotify(
    _ shouldNotify: Bool,
    forCharacteristic characteristicUUIDString: String,
    onService serviceUUIDString: String
  ) {

    guard let (characteristic, _) = self.characteristicByUUID(
      characteristicUUIDString,
      forService: serviceUUIDString
    ) else {
      // TODO
      return
    }

    self.setNotifyValue(shouldNotify, for: characteristic)
  }

  func fetchServicesAndCharacteristics(_ serviceUUIDs: [CBUUID]) {
    self.discoverServices(serviceUUIDs)
  }

  func fetchRSSI() {
    self.readRSSI()
  }
}
