//
//  Bluetooth.swift
//  Bluetooth
//
//  Created by Sara Pope on 10/19/21.
//

import Foundation
import CoreBluetooth

@objc(Bluetooth)
class Bluetooth: RCTEventEmitter {
  override static func moduleName() -> String! {
    return "Bluetooth"
  }

  let cbManager: CBCentralManager
  let notificationCenter: NotificationCenter

  var knownDevices: [CBPeripheral] = []
  var savedServiceUUIDs: [CBUUID] = []
  var readCallbacks: NSMutableDictionary
  var writeCallbacks: NSMutableDictionary
  var connections: [String: CBPeripheral]

  override class func requiresMainQueueSetup() -> Bool {
    return true
  }

  override init() {
    self.cbManager = CBCentralManager()
    self.notificationCenter = NotificationCenter.default

    self.readCallbacks = NSMutableDictionary()
    self.writeCallbacks = NSMutableDictionary()
    self.connections = Dictionary()

    super.init()

    self.registerForLocalNotifications()
  }

  deinit {
    unregisterForLocalNotifications()
  }

  override func supportedEvents() -> [String]! {
    return BluetoothEvents.asArray()
  }

  private func registerForLocalNotifications() {
    notificationCenter.addObserver(
      self,
      selector: #selector(bridgeReloading),
      name: .RCTBridgeWillReload,
      object: nil
    )
  }

  private func unregisterForLocalNotifications() {
    notificationCenter.removeObserver(self)
  }

  @objc
  func bridgeReloading() {
    cbManager.delegate = nil
  }

  @objc(getBluetoothStatus:resolve:reject:)
  func getBluetoothStatus(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(self.getBluetoothState().rawValue)
  }

  @objc(startDiscovery:options:resolve:reject:)
  func startDiscovery(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard isBluetoothReady() else {
      rejectOnBluetoothError(rejecter: reject)
      return
    }

    cbManager.delegate = self

    let serviceUUIDStrings = options["serviceUUIDs"] as? [String] ?? []
    let allowDuplicates = options["allowDuplicates"] ?? false

    let serviceUUIDs = handleServiceUUIDs(serviceUUIDStrings)

    cbManager.scanForPeripherals(
      withServices: serviceUUIDs,
      options: [CBCentralManagerScanOptionAllowDuplicatesKey: allowDuplicates]
    )
  }

  @objc(stopDiscovery:options:resolve:reject:)
  func stopDiscovery(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard isBluetoothReady() else {
      rejectOnBluetoothError(rejecter: reject)
      return
    }

    cbManager.stopScan()
  }

  @objc(getDiscoveredDevices:options:resolve:reject:)
  func getDiscoveredDevices(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard isBluetoothReady() else {
      rejectOnBluetoothError(rejecter: reject)
      return
    }

    resolve(knownDevices.map { $0.asDictionary() })
  }

  func handleDeviceConnection(_ device: CBPeripheral, resolver resolve: RCTPromiseResolveBlock) {
    if device.state != .connected {
      self.cbManager.connect(device, options: connectionOptions)
    }

    self.connections[device.uuid] = device

    resolve(device.state == .connected)
  }

  @objc(connectToDevice:options:resolve:reject:)
  func connectToDevice(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    withDevice(
      options,
      shouldBeConnected: false,
      rejecter: reject,
      completion: { device in
        let connectionOptions = device.getConnectionOptions(options)

        let shouldDiscover = options["shouldDiscover"] as? Bool ?? false

        if shouldDiscover == false {
          if device.state != .connected {
            self.cbManager.connect(device, options: connectionOptions)
          }

          self.connections[device.uuid] = device

          resolve(device.state == .connected)
        } else {
          self.startDiscovery(options, resolver: resolve, rejecter: reject)

          let scanTimeout = options["scanTimeoutSeconds"] as? TimeInterval ?? 2

          self.dispatchQueue(delay: scanTimeout) {
            self.cbManager.stopScan()

            if device.state != .connected {
              self.cbManager.connect(device, options: connectionOptions)
            }

            self.connections[device.uuid] = device

            resolve(device.state == .connected)
          }
        }
      }
    )
  }

  @objc(getConnectedDevices:options:resolve:reject:)
  func getConnectedDevices(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard isBluetoothReady() else {
      rejectOnBluetoothError(rejecter: reject)
      return
    }

    let serviceUUIDStrings = options["serviceUUIDs"] as? [String]

    guard serviceUUIDStrings != nil else {
      self.throwError(.serviceUUIDsRequired, rejecter: reject)
      return
    }

    let serviceUUIDs = self.handleServiceUUIDs(serviceUUIDStrings!)

    let connectedDevices = self.cbManager.retrieveConnectedPeripherals(withServices: serviceUUIDs)

    for device in connectedDevices where connections[device.uuid] != nil {
      connections[device.uuid] = device
    }

    resolve(connectedDevices.map { $0.asDictionary() })
  }

  @objc(disconnectFromDevice:options:resolve:reject:)
  func disconnectFromDevice(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    withDevice(
      options,
      shouldBeConnected: false,
      completion: { device in
        if device.state == .connected {
          self.cbManager.cancelPeripheralConnection(device)
        }

        connections.removeValue(forKey: device.uuid)

        resolve(true)
      }
    )
  }

  @objc(readFromDevice:options:resolve:reject:)
  func readFromDevice(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    withDevice(
      options,
      rejecter: reject,
      shouldBeConnected: true,
      completion: { device in
        let serviceUUID = options["serviceUUID"] as? String
        let characteristicUUID = options["characteristicUUID"] as? String

        guard let key = device.readFromDevice(characteristicUUID, forService: serviceUUID) else {
          self.throwError(.readFail, rejecter: reject)
          return
        }

        self.readCallbacks[key] = resolve
      }
    )
  }

  @objc(writeToDevice:options:resolve:reject:)
  func writeToDevice(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    withDevice(
      options,
      rejecter: reject,
      shouldBeConnected: true,
      completion: { device in
        let characteristicUUID = options["characteristicUUID"] as? String
        let serviceUUID = options["serviceUUID"] as? String
        let withResponse = options["withResponse"] as? Bool ?? true
        let writeData = options["writeData"] as? String

        guard let key = device.writeToDevice(
          characteristicUUID,
          forService: serviceUUID,
          withResponse: withResponse,
          writeData: writeData
        ) else {
          self.throwError(.readFail, rejecter: reject)
          return
        }

        self.writeCallbacks[key] = resolve
      }
    )
  }

  @objc(setCharacteristicNotify:options:resolve:reject:)
  func setCharacteristicNotify(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    withDevice(
      options,
      rejecter: reject,
      shouldBeConnected: true,
      completion: { device in
        device.setNotify(
          options["shouldNotify"] as! Bool,
          forCharacteristic: options["characteristicUUID"] as! String,
          onService: options["serviceUUID"] as! String
        )
      }
    )
  }

  @objc(fetchServicesAndCharacteristics:options:resolve:reject:)
  func fetchServicesAndCharacteristics(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    withDevice(
      options,
      rejecter: reject,
      shouldBeConnected: true,
      completion: { device in
        let serviceUUIDStrings = options["serviceUUIDStrings"] as? [String] ?? []

        guard serviceUUIDStrings.count > 0 || self.savedServiceUUIDs.count > 0 else {
          self.throwError(.serviceUUIDsRequired, rejecter: reject)
          return
        }

        let serviceUUIDs = serviceUUIDStrings.count > 0
          ? self.handleServiceUUIDs(serviceUUIDStrings)
          : self.savedServiceUUIDs

        device.fetchServicesAndCharacteristics(serviceUUIDs)
      }
    )
  }

  @objc(fetchRSSI:options:resolve:reject:)
  func fetchRSSI(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    withDevice(
      options,
      rejecter: reject,
      shouldBeConnected: true,
      completion: { device in
        device.fetchRSSI()
      }
    )
  }

  @objc(isDeviceConnected:options:resolve:reject:)
  func isDeviceConnected(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    withDevice(
      options,
      rejecter: reject,
      completion: {  device in
        resolve(device.isConnected)
      }
    )
  }

  @objc(getDevice:options:resolve:reject:)
  func getDevice(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    withDevice(
      options,
      rejecter: reject,
      completion: { device in
        resolve(device.asDictionary())
      }
    )
  }
}
