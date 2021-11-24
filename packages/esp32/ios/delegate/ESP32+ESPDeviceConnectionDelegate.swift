import Foundation
import ESPProvision

extension ESP32 {
  func getProofOfPossesion(forDevice: ESPDevice, completion: @escaping (String) -> Void) {
    completion(self.proofOfPossession)
  }
}
