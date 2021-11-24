//
//  Wifi.swift
//  Wifi
//
//  Created by Sara Pope on 10/27/21.
//
import Foundation
import NetworkExtension
import CoreLocation
import SystemConfiguration.CaptiveNetwork

@objc(Wifi)
class Wifi: NSObject, RCTBridgeModule  {
  override static func moduleName() -> String! {
    return "Wifi"
  }

  let locationManager: CLLocationManager
  let neHotspotConfigManager: NEHotspotConfigurationManager

  var permissionType: String = "whenInUse"

  override class func requiresMainQueueSetup() -> Bool {
    return true
  }

  override init() {
    self.locationManager = CLLocationManager()
    self.neHotspotConfigManager = NEHotspotConfigurationManager.shared

    super.init()
  }

  override func supportedEvents() -> [String]! {
    return WifiEvents.asArray()
  }

  @objc
  func bridgeReloading() {
    locationManager.delegate = nil
  }

  @objc
  func requestLocationPermission(_ type: String?) {
    if type != nil {
      self.permissionType = type
    }

    return self.requestPermission()
  }

  @objc
  func getCurrentNetwork(
    resolver resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    guard hasLocationPermission() else {
      rejectOnPermissionsError(rejecter: reject)
      return
    }

    resolve(self.getCurrentSSID())
  }

  @objc
  func connectToNetwork(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard hasLocationPermission() else {
      rejectOnPermissionsError(rejecter: reject)
      return
    }

    let ssid = options["ssid"] as? String

    guard let config = self.buildNetworkConfiguration(options, rejecter: reject) else {
      return
    }

    // typically, we'd check to see if the user was already connected to the given ssid before applying the config
    // but in this case we dont because `getConfiguredNetworks` will only return networks configured via this function
    // so if the user is already connected to a network, it won't show up in configured networks.

    neHotspotConfigManager.apply(config) { error in
      if let err = error as NSError? {
        self.throwError(self.handleConfigError(err), rejecter: reject)
      } else {
        resolve(ssid)
      }
      return
    }
  }

  @objc
  func disconnectFromNetwork(
    _ options: NSDictionary,
    resolver resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    guard hasLocationPermission() else {
      rejectOnPermissionsError(rejecter: reject)
      return
    }

    let ssid = options["ssid"] as? String

    guard ssid != nil else {
      // error: ssid required
      return
    }

    neHotspotConfigManager.getConfiguredSSIDs { (ssids: [String]!) -> Void in
      guard ssids != else {
        // we're already disconnected
        resolve(true)
        return
      }

      guard ssids.contains(ssid) else {
        self.throwError(.couldNotDisconnect, rejecter: reject)
        return
      }

      neHotspotConfigManager.removeConfiguration(forSSID: ssid)

      resolve(true)
    }
  }

  @objc
  func getConfiguredNetworks(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    guard hasLocationPermission() else {
      rejectOnPermissionsError(rejecter: reject)
      return
    }

    neHotspotConfigManager.getConfiguredSSIDs { (ssids) in
      resolve(ssids)
    }
  }

  @objc
  func isConnectedToNetwork(
    _ options: NSDictionary,
    resolver resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    guard hasLocationPermission() else {
      rejectOnPermissionsError(rejecter: reject)
      return
    }

    let ssid = options["ssid"] as? String

    resolve(self.getCurrentSSID() == ssid)
  }
}
