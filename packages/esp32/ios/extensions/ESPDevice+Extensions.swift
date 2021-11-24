import Foundation
import ESPProvision

extension ESPDevice {
  func asDictionary(_ type: TransportType) -> NSMutableDictionary {
    let dict = NSMutableDictionary()

    dict.setValue("deviceName", self.deviceName)
    dict.setValue("isSessionEstablished", self.session.isEstablished)
    dict.setValue("isConfigured", self.transportLayer.isDeviceConfigured())
    dict.setValue("connectionStatus", self.connectionStatus)
    dict.setValue("proofOfPossession", self.proofOfPossession)
    dict.setValue("capabilities", self.capabilities)
    dict.setValue("securityType", self.security)
    dict.setValue("transportType", self.transport)
    dict.setValue("versionInfo", self.versionInfo)

    if type == .ble {
      dict.setValue("serviceUUID", self.name)
      dict.setValue("canRead", self.espBleTransport.peripheralCanRead)
      dict.setValue("canWrite", self.espBleTransport.peripheralCanWrite)
    }
  }
}
