import { useCallback } from "react";
import { Linking, Platform } from "react-native";
import * as IntentLauncher from "expo-intent-launcher";
import Constants from "expo-constants";

export function useOpenDeviceSettings(packageName?: string) {
  const openDeviceSettings = useCallback(() => {
    if (Platform.OS === "android") {
      const pkgName = Constants.manifest?.android?.package ?? packageName;

      return IntentLauncher.startActivityAsync(
        IntentLauncher.ACTION_APPLICATION_DETAILS_SETTINGS,
        { data: pkgName }
      );
    } else {
      return Linking.openSettings();
    }
  }, []);

  return openDeviceSettings;
}
