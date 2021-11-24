#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(ESP32, NSObject)

RCT_EXTERN_METHOD(getBluetoothStatus: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startDiscovery: (nullable NSDictionary *)options
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseResolveBlock)reject)

RCT_EXTERN_METHOD(stopDiscovery: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(refreshDiscoveredDevices: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getDiscoveredDevices: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(connectToDevice: (nonnull NSDictionary *)options
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseResolveBlock)reject)

RCT_EXTERN_METHOD(disconnectFromDevice: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseResolveBlock)reject)

RCT_EXTERN_METHOD(scanForWifiNetworks: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseResolveBlock)reject)

RCT_EXTERN_METHOD(provisionDevice: (nullable NSDictionary *)options
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseResolveBlock)reject)

RCT_EXTERN_METHOD(sendDataToDevice: (nonnull NSDictionary *)options
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseResolveBlock)reject)

@end
