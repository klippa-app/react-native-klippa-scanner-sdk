import * as React from 'react';
import {StyleSheet, View, Text, Button, Alert} from 'react-native';
import KlippaScannerSDK from '@klippa/react-native-klippa-scanner-sdk';

export default function App() {
  const [result, setResult] = React.useState<string | undefined>();

  function startScanner() {
    KlippaScannerSDK.getCameraResult({
      License: '{your-license}',
    })
      .then((cameraResult: any) => {
        setResult(`Scanned ${cameraResult.Images.length} image(s)`);
      })
      .catch((reject: any) => {
        console.log(reject.toString());
        Alert.alert(reject.toString());
      });
  }

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
      <Button
        title="Start scanner"
        color="#00BC4A"
        onPress={() => startScanner()}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
