//
//  ESP32.swift
//  ESP32
//
//  Created by Sara Pope on 10/29/21.
//
import Foundation
import CoreBluetooth
import ESPProvision
import React

@objc
class ESP32: RCTEventEmitter {
  override static func moduleName() -> String {
    return "ESP32"
  }

  let cbManager: CBPeripheralManager?
  let espManager: ESPProvisionManager
  let knownDevices: [ESPDevice]?
  let espDevice: ESPDevice?

  override class func requiresMainQueueSetup() -> Bool {
    return true
  }

  override init() {
    self.cbManager = CBPeripheralManager()
    self.espManager = ESPProvisionManager.shared
    self.notificationCenter = NotificationCenter.default

    self.knownDevices = []
    self.espDevice = nil

    super.init()

    self.registerForLocalNotifications()
  }

  deinit {
    unregisterForLocalNotifications()
  }

  override func supportedEvents() -> [String]! {
    return ESP32Events.asArray()
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

  @objc
  func getBluetoothStatus(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(self.getBluetoothState().rawValue)
  }

  @objc
  func startDiscovery(
    _ options: NSDictionary?,
    resolver resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    let mode = options["transportMode"] ?? "ble"
    let transportMode = mode === "ble" ? .ble : .softap

    if transportMode == .ble {
      guard isBluetoothReady() else {
        rejectOnBluetoothError(rejecter: reject)
        return
      }
    }

    espManager.searchESPDevices(devicePrefix: options?["prefix"] ?? "", transport: transportMode) { devices, error in
      let hasError = error != nil

      self.knownDevices = devices

      fireEvent(
        withName: .discoverDevices,
        dataKey: hasError ? "error" : "devices",
        data: hasError ? error.description : devices.map({ $0.asDictionary() })
      )

      resolve(true)
    }
  }

  @objc
  func stopDiscovery(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    espManager.stopESPDevicesSearch()
    resolve(true)
  }

  @objc
  func refreshDiscoveredDevices(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    espManager.refreshDeviceList() { devices, error in
      let hasError = error != nil

      self.knownDevices = devices

      fireEvent(
        withName: .discoverDevices,
        dataKey: hasError ? "error" : "devices",
        data: hasError ? error.description : devices.map({ $0.asDictionary() })
      )

      resolve(true)
    }
  }

  @objc
  func getDiscoveredDevices(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(knownDevices.map({ $0.asDictionary() }))
  }

  @objc
  func connectToDevice(
    _ options: NSDictionary,
    resolver resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    if options["transportMode"] == "ap" {
      espManager.createESPDevice(
        deviceName: options["name"],
        transport: .softap,
        security: .secure,
        proofOfPossession: options["proofOfPossession"] ?? "",
        softAPPassword: options["wifiPassword"]
      ) { espDeviceInstance, _ in
        guard espDeviceInstance else {
          throwError(.deviceNotFound, rejecter: reject)
          return
        }

        espDevice = espDeviceInstance
      }
    } else {
      let isScanning = false

      if knownDevices.count == 0 {
        isScanning = true
        self.startScan(options, resolver: resolve, rejecter: reject)
      }

      self.dispatchQueue(delay: 2) {
        guard let foundDevice = knownDevices?.first(where: { esp -> Bool in esp.name == options["name"] }) else {
          throwError(.deviceNotFound, rejecter: reject)
          return
        }

        if isScanning {
          self.stopScan()
          isScanning = false
        }

        espDevice = foundDevice
        espDevice.security = options["proofOfPossession"] == nil ? .unsecure : .secure
      }
    }

    espDevice.connect(delegate: self) { status in
      let evt: DeviceConnectivity

      switch status {
      case .connected:
        evt = .connect
      case let .failedToConnect(error):
        var message = ""

        switch error {
        case .securityMismatch, .versionInfoError:
          message = error.description
        default:
          message = error.description + "\nCheck proof of possession"
        }

        evt = .connectFail
      default:
        evt = .disconnect
      }

      fireEvent(
        withName: evt,
        message: message ?? nil,
        dataKey: "device",
        data: device.asDictionary()
      )

      resolve(espDevice.asDictionary())
    }
  }

  @objc
  func disconnectFromDevice(
    _ resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    guard espDevice else {
      // already disconnected
      resolve(true)
      return
    }

    espDevice.disconnect()
    resolve(true)
  }

  @objc
  func scanForWifiNetworks(
    _ resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    guard espDevice else {
      return
    }

    espDevice.scanWifiList { wifiList, error in
      let hasError = error != nil

      let networks = wifiList?.count > 0 ? wifiList.sorted { $0.rssi > $1.rssi }.map { wifi in
        ["ssid": wifi.ssid, "auth": wifi.auth.rawValue, "rssi": wifi.rssi] : []

      fireEvent(
        withName: .discoverWifiNetworks,
        dataKey: hasError ? "error" : "networks",
        data: hasError ? error.description : networks
      )

      resolve(true)
    }
  }

  @objc
  func provisionDevice(
    _ options: NSDictionary,
    resolver resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    guard espDevice else {
      throwError(.deviceNotFound, rejecter: reject)
      return
    }

    espDevice.provision(ssid: options["ssid"], passPhrase: options["passphrase"]) { status, error in
      guard error != nil else {
        resolve([
          "error": error.description
        ])
        return
      }

      let status: Provisioning

      switch status {
      case .success:
        status = .completed
      case let .failure(error):
        switch error {
        case .configurationError:
          status = .configFailed
        case .sessionError:
          status = .initFailed
        case .wifiStatusDisconnected:
          status = .applyFailed
        default:
          status = .failed
        }
      case .configApplied:
        status = .configApplied
      }

      resolve([
        "status": status,
        "device": espDevice.asDictionary()
      ])
    }
  }

  @objc
  func sendDataToDevice(
    _ options: NSDictionary,
    resolver resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    guard espDevice else {
      throwError(.deviceNotFound, rejecter: reject)
      return
    }

    guard let dataToSend = options["data"].fromBase64 else {
      throwError(.malformedData, rejecter: reject)
      return
    }

    espDevice.sendData(path: options["endpoint"], data: dataToSend) { data, error in
      guard error != nil else {
        resolve([
          "error": error.description
        ])
        return
      }

      resolve(data)
    }
  }
}
