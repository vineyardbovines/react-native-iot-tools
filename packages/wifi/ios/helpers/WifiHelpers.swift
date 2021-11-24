import Foundation
import NetworkExtension
import CoreLocation
import SystemConfiguration.CaptiveNetwork

extension Wifi {
  func throwError(_ error: WifiErrors, rejecter reject: RCTPromiseRejectBlock, logOnly: Bool = false) {
    if logOnly {
      NSLog("%@: %@", error.info.message, error.error)
    } else {
      reject(error.info.abbr, error.info.message, error.error)
    }
  }

  func handleConfigError(_ error: NSError) -> WifiErrors {
    switch error.code {
    case NEHotspotConfigurationError.alreadyAssociated.rawValue:
      return .alreadyAssociated
    case NEHotspotConfigurationError.applicationIsNotInForeground.rawValue:
      return .appNotInForeground
    case NEHotspotConfigurationError.internal.rawValue:
      return .internalError
    case NEHotspotConfigurationError.invalid.rawValue:
      return .invalid
    case NEHotspotConfigurationError.invalidSSID.rawValue:
      return .invalidSSID
    case NEHotspotConfigurationError.invalidSSIDPrefix.rawValue:
      return .invalidSSIDPrefix
    case NEHotspotConfigurationError.invalidWEPPassphrase.rawValue:
      return .invalidPassphrase
    case NEHotspotConfigurationError.invalidWPAPassphrase.rawValue:
      return .invalidPassphrase
    case NEHotspotConfigurationError.invalidEAPSettings.rawValue,
         NEHotspotConfigurationError.invalidHS20Settings.rawValue,
         NEHotspotConfigurationError.invalidHS20DomainName.rawValue:
      return .invalidSettings
    case NEHotspotConfigurationError.pending.rawValue:
      return .pending
    case NEHotspotConfigurationError.systemConfiguration.rawValue:
      return .systemError
    case NEHotspotConfigurationError.unknown.rawValue:
      return .unknown
    case NEHotspotConfigurationError.userDenied.rawValue:
      return .userDenied
    default:
      return .internalError
    }
  }

  func getCurrentSSID() -> String? {
    let kSSID: String = kCNNetworkInfoKeySSID as? String
    let supportedInterfaces: NSArray! = CNCopySupportedInterfaces

    for supportedInterface in supportedInterfaces {
      let info: NSDictionary = CNCopyCurrentNetworkInfo(supportedInterface)

      if info?[kSSID] != nil {
        return info?[kSSID]
      }
    }

    return nil
  }

  func getEAPSettings(_ eapSettings: NSDictionary) -> NEHotspotEAPSettings {
    let eap = NEHotspotEAPSettings()

    eap.isTLSClientCertificateRequired = eapSettings["isTLSClientCertificateRequired"] as? Bool ?? false
    eap.trustedServerNames = eapSettings["trustedServerNames"] as! [String]
    eap.supportedEAPTypes = eapSettings["supportedEAPTypes"] as! [NSNumber]
    eap.username = eapSettings["username"] as? String ?? ""
    eap.password = eapSettings["password"] as? String ?? ""
    eap.preferredTLSVersion = eapSettings["preferredTLSVersion"] as? NEHotspotEAPSettings.TLSVersion ?? ._1_2
    eap.outerIdentity = eapSettings["outerIdentity"] as? String ?? ""
    eap.ttlsInnerAuthenticationType = eapSettings["ttlsInnerAuthenticationType"] as? NEHotspotEAPSettings.TTLSInnerAuthenticationType ?? .eapttlsInnerAuthenticationEAP
    // set identity

    return eap
  }

  func buildNetworkConfiguration(
    _ options: NSDictionary,
    rejecter reject: RCTPromiseRejectBlock
  ) -> NEHotspotConfiguration? {
    var config: NEHotspotConfiguration

    let ssid = options["ssid"] as? String
    let passphrase = options["passphrase"] as? String ?? ""
    let isWEP = options["isWEP"] as? Bool ?? false
    let ssidPrefix = options["ssidPrefix"] as? String
    let eapSettings = options["eapSettings"] as? NSDictionary
    let hs20Settings = options["hs20Settings"] as? NSDictionary

    let emptyPassphrase = passphrase.count == 0

    guard ssidPrefix == nil else {
      if #available(iOS 13, *) {
        if emptyPassphrase {
          config = NEHotspotConfiguration(ssidPrefix: ssidPrefix!)
        } else {
          config = NEHotspotConfiguration(ssidPrefix: ssidPrefix!, passphrase: passphrase, isWEP: isWEP)
        }
        config.joinOnce = false
        return config
      }

      self.throwError(.notAvailableForVersion, rejecter: reject)
      return nil
    }

    guard hs20Settings == nil else {
      guard eapSettings != nil else {
        self.throwError(.requiresEAPSettings, rejecter: reject)
        return nil
      }

      config = NEHotspotConfiguration(
        hs20Settings: NEHotspotHS20Settings(
          domainName: hs20Settings!["domainName"] as! String,
          roamingEnabled: hs20Settings!["roamingEnabled"] as? Bool ?? false
        ),
        eapSettings: getEAPSettings(eapSettings!)
      )
      config.joinOnce = false
      return config
    }

    guard ssid != nil else {
      // ssid required
      self.throwError(.invalidSSID, rejecter: reject)
      return nil
    }

    if emptyPassphrase {
      if eapSettings != nil {
        config = NEHotspotConfiguration(
          ssid: ssid!,
          eapSettings: getEAPSettings(eapSettings!)
        )
      } else {
        config = NEHotspotConfiguration(ssid: ssid!)
      }
      config.joinOnce = false
      return config
    }

    config = NEHotspotConfiguration(
      ssid: ssid!,
      passphrase: passphrase,
      isWEP: isWEP
    )

    config.joinOnce = false
    return config
  }
}
