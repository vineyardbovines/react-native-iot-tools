import Foundation
import NetworkExtension
import CoreLocation
import SystemConfiguration.CaptiveNetwork

extension Wifi: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    var status: CLAuthorizationStatus

    if #available(iOS 14, *) {
      status = manager.authorizationStatus
    } else {
      status = CLLocationManager.authorizationStatus()
    }

    repeat {
      self.requestPermission()
    } while status == .notDetermined
  }
}
