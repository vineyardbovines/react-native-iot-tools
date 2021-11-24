import Foundation
import CoreLocation

extension Wifi {
  var authStatus {
    if #available(iOS 14, *) {
      return locationManager.authorizationStatus
    } else {
      return CLLocationManager.authorizationStatus()
    }
  }

  func hasLocationPermission() -> Bool {
    repeat {
      self.requestPermission()
    } while authStatus == .notDetermined

    return authStatus.authorizedAlways || authStatus == .authorizedWhenInUse
  }

  func requestPermission() {
    if self.permissionType == "always" {
      return locationManager.requestAlwaysAuthorization()
    }

    return locationManager.requestWhenInUseAuthorization()
  }

  func rejectOnPermissionsError(rejecter reject: RCTPromiseRejectBlock) {
    var err: WifiErrors = .unknown

    if authStatus == .denied {
      err = .locationPermissionDenied
    } else if authStatus == .restricted {
      err = .locationPermissionRestricted
    }

    self.throwError(err, rejecter: reject)
  }
}
