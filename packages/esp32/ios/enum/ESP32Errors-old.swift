import Foundation

enum ESP32ErrorsOld {
  // session
  case sessionInit
  case sessionNotEstablished
  case sendData
  case softAPConnectionFailure
  case securityMismatch
  case versionInfo
  case bleFailedToConnect
  case encryption
  // CSS 
  case cameraNotAvailable
  case cameraAccessDenied
  case avCaptureDeviceInput
  case videoInput
  case videoOutput
  case invalidQRCode
  case espDeviceNotFound
  case softAPSearchNotSupported
  // provision 
  case provisionSession
  case provisionConfig
  case wifiStatus
  case wifiAuth
  case networkNotFound
  case wifiStatusUnknown
  case unknownError
  // transport
  case deviceUnreachable
  case communication
  // wifi scan
  case emptyWifiConfigData
  case emptyWifiList
  case wifiScanRequest

  var info: (code: Int, abbr: String, message: String)
}
