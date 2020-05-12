# react-native-klippa-scanner-sdk

## SDK License
Please be aware you need to have a license to use this SDK.
If you would like to use our scanner, please contact us [here](https://www.klippa.com/en/ocr/ocr-sdk/)

## Getting started
### Android

Edit the file `android/build.gradle`, add the Klippa Maven repository:

```maven
allprojects {
    repositories {
        // ... other repositories

        maven {
            credentials {
                username "{your-username}"
                password "{your-password}"
            }
            url "https://custom-ocr.klippa.com/sdk/android/maven"
        }
    }
}
```

Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

### iOS

Edit the file `ios/Podfile`, add the Klippa CocoaPod:
```
target 'YourApplicationName' do
  # Pods for YourApplicationName
  // ... other pods

  pod 'Klippa-Scanner', podspec: 'https://custom-ocr.klippa.com/sdk/ios/specrepo/{your-username}/{your-password}/KlippaScanner/0.0.13.podspec'
end
```

Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

### React native

`$ npm install @klippa/react-native-klippa-scanner-sdk --save`

### Mostly automatic installation

`$ react-native link @klippa/react-native-klippa-scanner-sdk`

## Usage
```javascript
import KlippaScannerSDK from '@klippa/react-native-klippa-scanner-sdk';

// TODO: What to do with the module?
KlippaScannerSDK;
```

## About Klippa

[Klippa](https://www.klippa.com/en) is a scale-up from [Groningen, The Netherlands](https://goo.gl/maps/CcCGaPTBz3u8noSd6) and was founded in 2015 by six Dutch IT specialists with the goal to digitize paper processes with modern technologies.

We help clients enhance the effectiveness of their organization by using machine learning and OCR. Since 2015 more than a 1000 happy clients have been served with a variety of the software solutions that Klippa offers. Our passion is to help our clients to digitize paper processes by using smart apps, accounts payable software and data extraction by using OCR.

## License

The MIT License (MIT)
