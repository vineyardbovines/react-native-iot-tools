import React from "react";
import { Platform, Pressable, StyleProp, View, ViewStyle } from "react-native";
import { Camera } from "expo-camera";
import { BarCodeScanner } from "expo-barcode-scanner";
import * as Haptics from "expo-haptics";
import { Ionicons, MaterialIcons } from "@expo/vector-icons";

export type QRCodeScannerProps = {
  onReadQRCode: (e: {
    type: keyof typeof BarCodeScanner.Constants.BarCodeType;
    data: string;
  }) => void;
  handleNoPermission: () => void | React.ReactElement;
  useHaptics?: boolean;
  loader?: React.ReactElement;
  showCameraControlButtons?: boolean;
  cameraControlButtonStyle?: StyleProp<ViewStyle>;
  cameraControlButtonIconStyle?: StyleProp<ViewStyle>;
};

/**
 * QRCodeScannerComponent
 *
 * @param props
 * @param props.onReadQRCode - function to execute when the QR code is read
 * @param props.handleNoPermission - function to execute when the user has not granted the appropriate camera permission (can be either a plain function or a component)
 * @param props.loader - [optional] loader element to display when loading
 * @param props.useHaptics - [optional] whether or not to enable haptics. haptics fire when the QR code is read successfully. defaults to true
 * @param props.showCameraControlButtons - [optional] whether or not to show camera control buttons (flash and camera front/back)
 * @param props.cameraControlButtonStyle - [optional] CSS style for the camera control buttons
 * @param props.cameraControlButtonIconStyle - [optional] CSS style for the camera control icons
 */
function QRCodeScannerComponent({
  onReadQRCode,
  handleNoPermission,
  loader,
  useHaptics = true,
  showCameraControlButtons = false,
  cameraControlButtonStyle,
  cameraControlButtonIconStyle
}: QRCodeScannerProps): React.ReactElement {
  const { FlashMode, Type } = Camera.Constants;

  const [hasPermission, setHasPermission] = React.useState<boolean | null>(
    null
  );
  const [flash, setFlash] = React.useState<keyof typeof FlashMode>(
    FlashMode.auto
  );
  const [type, setType] = React.useState<keyof typeof Type>(Type.back);

  // check camera permission on load
  React.useEffect(() => {
    (async () => {
      const { status } = await Camera.requestPermissionsAsync();
      setHasPermission(status === "granted");
    })();
  }, []);

  const handleCodeRead = React.useCallback(
    async (e: {
      type: keyof typeof BarCodeScanner.Constants.BarCodeType;
      data: string;
    }) => {
      if (useHaptics) {
        await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      }
      onReadQRCode(e);
    },
    []
  );

  const flashIcon = React.useMemo(
    () =>
      flash === FlashMode.auto ? "ios-flash-outline" : "ios-flash-off-outline",
    [flash]
  );

  const buttonStyle = React.useMemo(() => {
    if (cameraControlButtonStyle) return cameraControlButtonStyle;

    return {
      backgroundColor: "black",
      p: "10px",
      borderRadius: "100%"
    };
  }, [cameraControlButtonStyle]);

  const buttonIconStyle = React.useMemo(() => {
    if (cameraControlButtonIconStyle) return cameraControlButtonIconStyle;

    return {
      size: 30,
      color: "white"
    };
  }, [cameraControlButtonIconStyle]);

  React.useEffect(() => {
    if (
      hasPermission === false &&
      !React.isValidElement(handleNoPermission() as React.ReactElement)
    ) {
      return handleNoPermission() as void;
    }
  }, [hasPermission]);

  if (hasPermission === null) return loader ?? <View />;

  if (
    hasPermission === false &&
    React.isValidElement(handleNoPermission() as React.ReactElement)
  ) {
    return handleNoPermission() as React.ReactElement;
  }

  return (
    <View style={{ flex: 1 }}>
      {showCameraControlButtons ? (
        <Camera
          style={{ flex: 1 }}
          onBarCodeScanned={handleCodeRead}
          barCodeScannerSettings={[BarCodeScanner.Constants.BarCodeType.qr]}
          type={Camera.Constants.Type.back}
          flashMode={Camera.Constants.FlashMode.auto}
        >
          <View style={{ flex: 1, backgroundColor: "transparent" }} />
          <View
            style={{
              flexDirection: "row",
              alignItems: "center",
              justifyContent: "space-around",
              height: 100,
              backgroundColor: "transparent",
              width: "100%"
            }}
          >
            <Pressable
              onPress={() =>
                flash === FlashMode.auto
                  ? setFlash(FlashMode.off)
                  : setFlash(FlashMode.auto)
              }
              {...buttonStyle}
            >
              <Ionicons name={flashIcon} {...buttonIconStyle} />
            </Pressable>
            <Pressable
              onPress={() =>
                type === Type.back ? setType(Type.front) : setType(Type.back)
              }
              {...buttonStyle}
            >
              <MaterialIcons
                name={`flash-camera-${Platform.OS}`}
                {...buttonIconStyle}
              />
            </Pressable>
          </View>
        </Camera>
      ) : (
        <Camera
          style={{ flex: 1 }}
          onBarCodeScanned={handleCodeRead}
          barCodeScannerSettings={[BarCodeScanner.Constants.BarCodeType.qr]}
          type={Camera.Constants.Type.back}
          flashMode={Camera.Constants.FlashMode.auto}
        />
      )}
    </View>
  );
}

export const QRCodeScanner = React.forwardRef(
  React.memo(QRCodeScannerComponent)
);
