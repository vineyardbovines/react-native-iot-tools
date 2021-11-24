//
//  Bluetooth+CBCentralManagerDelegate.swift
//  Bluetooth
//
//  Created by Sara Pope on 10/19/21.
//

import Foundation
import CoreBluetooth

extension Bluetooth: CBCentralManagerDelegate {
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    let btState = getBluetoothState()

    if btState == .poweredOn {
      if #available(iOS 13.0, *) {
        cbManager.registerForConnectionEvents(
          options: [CBConnectionEventMatchingOption.serviceUUIDs: savedServiceUUIDs]
        )
      }
    }

    self.fireEvent(
      withName: .stateChange,
      device: nil,
      dataKey: "state",
      data: btState.rawValue,
      delay: nil
    )
  }

  public func centralManager(
    _ central: CBCentralManager,
    connectionEventDidOccur event: CBConnectionEvent,
    for peripheral: CBPeripheral
  ) {
    var message: String

    switch event {
    case .peerConnected:
      message = "Peer connected"
    case .peerDisconnected:
      message = "Peer disconnected"
    default:
      message = "Peer connection event"
    }

    self.fireEvent(
      withName: .connectionEvent,
      device: peripheral.asDictionary(),
      message: message,
      delay: nil
    )
  }

  public func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any],
    rssi RSSI: NSNumber
  ) {
    guard peripheral.name != nil else {
      return
    }

   self.knownDevices.append(peripheral)

    self.fireEvent(
      withName: .discover,
      device: peripheral.asDictionary(rssi: RSSI),
      delay: nil
    )
  }

  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.delegate = self

    NSLog("saved service UUIDs %@", savedServiceUUIDs)

    if peripheral.state == .connected {
      peripheral.discoverServices([])
      NSLog("services %@", peripheral.services ?? "")

      fireEvent(
        withName: .connect,
        device: peripheral.asDictionary(),
        delay: 3
      )
    }
  }

  public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    if error != nil {
      self.fireEvent(
        withName: .connectFail,
        device: peripheral.asDictionary(),
        message: "A connection error occurred",
        dataKey: "error",
        data: error,
        delay: nil
      )
      return
    }

    self.fireEvent(
      withName: .connectFail,
      device: peripheral.asDictionary(),
      delay: nil
    )
  }

  public func centralManager(
    _ central: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral,
    error: Error?
  ) {
    if error != nil {
      print(error)
      self.fireEvent(
        withName: .disconnect,
        device: peripheral.asDictionary(),
        message: "Failed to disconnect or device was turned off",
        dataKey: "error",
        data: error,
        delay: nil
      )
      return
    }

    self.fireEvent(
      withName: .disconnect,
      device: peripheral.asDictionary(),
      delay: nil
    )
  }
}
