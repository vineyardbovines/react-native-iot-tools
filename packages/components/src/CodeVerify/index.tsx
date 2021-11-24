import React from "react";
import {
  TextInput,
  View,
  Pressable,
  Text,
  StyleProp,
  ViewStyle,
  TextStyle
} from "react-native";
import { Formik, FormikValues } from "formik";
import * as Yup from "yup";

export type CodeVerifyProps = {
  onSubmit: (e: FormikValues) => void;
  codeLength?: number;
  inputContainerStyle: StyleProp<ViewStyle>;
  digitContainerStyle: StyleProp<ViewStyle>;
  digitTextStyle: StyleProp<TextStyle>;
};

type CodeVerifyInitialValues = {
  code: string;
};

/**
 * CodeVerify - renders an SMS code verification component
 *
 * @param props
 * @param props.codeLength - the length of the SMS code, defaults to 6
 * @param props.onSubmit - callback that handles the code submission
 * @param props.digitContainerStyle - CSS style of the number container
 * @param props.digitTextStyle - CSS style of the digit itself
 * @param props.inputContainerStyle - CSS style of the entire input container
 */
function CodeVerifyComponent({
  codeLength = 6,
  onSubmit,
  digitContainerStyle,
  digitTextStyle,
  inputContainerStyle
}: CodeVerifyProps) {
  const initialValues: CodeVerifyInitialValues = {
    code: ""
  };

  const validationSchema = Yup.object().shape({
    code: Yup.string()
      .required()
      .min(codeLength)
  });

  const [code, setCode] = React.useState("");

  const codeDigitsArray = Array.from({ length: codeLength });

  const ref = React.useRef<TextInput>(null);

  const handleOnPress = () => {
    ref?.current?.focus();
  };

  const toDigitInput = (_value: unknown, idx: number) => {
    const emptyInputChar = " ";
    const digit = code[idx] || emptyInputChar;

    return (
      <View key={idx} {...digitContainerStyle}>
        <Text {...digitTextStyle}>{digit}</Text>
      </View>
    );
  };

  return (
    <Formik
      initialValues={initialValues}
      validationSchema={validationSchema}
      validateOnMount
      onSubmit={onSubmit}
    >
      {({ handleSubmit, setFieldValue }) => {
        return (
          <View style={{ width: "100%", alignItems: "center" }}>
            <Pressable onPress={handleOnPress} {...inputContainerStyle}>
              {codeDigitsArray.map(toDigitInput)}
            </Pressable>
            <TextInput
              ref={ref}
              value={code}
              name="code"
              onChangeText={(text: string): void => {
                setCode(text);
                setFieldValue("code", text);
              }}
              keyboardType="number-pad"
              returnKeyType="done"
              textContentType="oneTimeCode"
              maxLength={codeLength}
              onSubmitEditing={handleSubmit}
              style={{
                position: "absolute",
                height: 0,
                width: 0,
                opacity: 0
              }}
            />
          </View>
        );
      }}
    </Formik>
  );
}

export const CodeVerify = React.forwardRef(React.memo(CodeVerifyComponent));
