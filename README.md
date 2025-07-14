[![Npm version][npm-version]][npm-url]

[npm-version]:https://img.shields.io/npm/v/@klippa/react-native-klippa-scanner-sdk.svg
[npm-url]:https://www.npmjs.com/package/@klippa/react-native-klippa-scanner-sdk

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

If you're using gradle 7+ you will need to change `copyDownloadableDepsToLibs` in the `app/build.gradle`.
It should now look like:

```maven
task copyDownloadableDepsToLibs(type: Copy) {
    from configurations.implementation
    into 'libs'
}

```

### iOS

Edit the file `ios/Podfile`, add the Klippa CocoaPod:
```
// Add this to the top of your file:
// Edit the platform to a minimum of 13.0, our SDK doesn't support earlier versions.

platform :ios, '13.0'

if "#{ENV['KLIPPA_SCANNER_SDK_USERNAME']}" == ""
  ENV['KLIPPA_SCANNER_SDK_USERNAME'] = '{your-username}'
end

if "#{ENV['KLIPPA_SCANNER_SDK_PASSWORD']}" == ""
  ENV['KLIPPA_SCANNER_SDK_PASSWORD'] = '{your-password}'
end

# // Edit the Runner config to add the pod:

target ‘YourApplicationName’ do
  // ... other instructions

  // Add this below `use_react_native`

  if "#{ENV['KLIPPA_SCANNER_SDK_URL']}" == ""
    file_path = File.expand_path('../node_modules/@klippa/react-native-klippa-scanner-sdk/ios/.sdk_repo', __dir__)
    ENV['KLIPPA_SCANNER_SDK_URL'] = File.read(file_path).strip
  end

  if "#{ENV['KLIPPA_SCANNER_SDK_VERSION']}" == ""
    file_path = File.expand_path('../node_modules/@klippa/react-native-klippa-scanner-sdk/ios/.sdk_version', __dir__)
    ENV['KLIPPA_SCANNER_SDK_VERSION'] = File.read(file_path).strip
  end

  pod 'Klippa-Scanner', podspec: "#{ENV['KLIPPA_SCANNER_SDK_URL']}/#{ENV['KLIPPA_SCANNER_SDK_USERNAME']}/#{ENV['KLIPPA_SCANNER_SDK_PASSWORD']}/KlippaScanner/#{ENV['KLIPPA_SCANNER_SDK_VERSION']}.podspec"
  
end
```

Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

Edit the file `ios/{project-name}/Info.plist` and add the `NSCameraUsageDescription` value:
```
...
<key>NSCameraUsageDescription</key>
<string>Access to your camera is needed to photograph documents.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Access to your photo library is used to save the images of documents.</string>
...
```

### React native

`$ npm install @klippa/react-native-klippa-scanner-sdk --save`

Don't forget to run `pod install` in the ios folder when running the iOS app.

### Mostly automatic installation (only for versions of React Native lower than 0.60, later versions have auto-linking)

`$ react-native link @klippa/react-native-klippa-scanner-sdk`

## Usage
```javascript
import KlippaScannerSDK from '@klippa/react-native-klippa-scanner-sdk';

// Ask for camera permission.
KlippaScannerSDK.getCameraPermission().then((authStatus) => {
    if (authStatus.Status !== "Authorized") {
        // Do something here to tell the user how they should enable the camera.
        Alert.alert("No access to camera");
        return;
    }

    // Start the scanner.
    KlippaScannerSDK.getCameraResult({
        // Required
        License: "{license-received-by-klippa}",
    
        // Optional.

        // Ability to disable/hide the shutter button (only works when a model is supplied as well).
        ShutterButton: {allowShutterButton: true, hideShutterButton: false},
    
        // Whether the crop mode (auto edge detection) should be enabled by default.
        DefaultCrop: true,
    
        // Define the max resolution of the output file. It’s possible to set only one of these values. We will make sure the picture fits in the given resolution. We will also keep the aspect ratio of the image. Default is max resolution of camera.
        ImageMaxWidth: 1920,
        ImageMaxHeight: 1080,
    
        // Set the output quality (between 0-100) of the jpg encoder. Default is 100.
        ImageMaxQuality: 95,
    
        // The camera mode for scanning one part documents.
        CameraModeSingle?: {name: "Single Document Mode", message: "Description of Camera Mode"};

        // The camera mode for scanning documents that consist of multiple pages.
        CameraModeMulti?: {name: "Multiple Document Mode", message: "Description of Camera Mode"};

        // The camera mode for scanning long documents in separate parts.
        CameraModeSegmented?: {name: "Segmented Document Mode", message: "Description of Camera Mode"};

        // To limit the amount of images that can be taken.
        ImageLimit: 10,
        
        // The message to display when the limit has been reached.
        ImageLimitReachedMessage: "You have reached the image limit",

        // Whether to go to the Review Screen once the image limit has been reached. (default false)
        ShouldGoToReviewScreenWhenImageLimitReached: false,

        // Whether the user must confirm the taken photo before the SDK continues.
        UserShouldAcceptResultToContinue: false,

        // Whether to hide or show the rotate button in the Review Screen. (default shown/true)
        UserCanRotateImage: true,

        // Whether to hide or show the cropping button in the Review Screen. (default shown/true)
        UserCanCropManually: true,

        // Whether to hide or show the color changing button in the Review Screen. (default shown/true)
        UserCanChangeColorSetting: true,

        // What the default color conversion will be (grayscale, original, enhanced).
        DefaultColor: "original",

        // Whether to perform on-device OCR after scanning completes.
        PerformOnDeviceOCR: false,

        // What the output format will be (jpeg, pdfMerged, pdfSingle). (Default jpeg)
        OutputFormat: "jpeg",

        // The lower threshold before the warning message informs the environment is too dark (default 0).
        BrightnessLowerThreshold: 0,

        // The upper threshold before the warning message informs the environment is too bright (default 6).
        BrightnessUpperThreshold: 6,
    
        // Optional. Only affects Android.
    
        // Where to put the image results.
        StoragePath: "/sdcard/scanner",
    
        // The filename to use for the output images, supports replacement tokens %dateTime% and %randomUUID%.
        OutputFilename: "KlippaScannerExample-%dateTime%-%randomUUID%",
    
        // The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 50).
        ImageMovingSensitivityAndroid: 50,

        // If you would like to use a custom model for object detection. Model + labels file should be packaged in your bundle.
        Model: {name: "model", labelsName: "labels"},
        
        // If you would like to enable automatic capturing of images.
        Timer: {enabled: true, duration: 0.4},

        // To add extra horizontal and / or vertical padding to the cropped image.
        CropPadding: {width: 100, height: 100},

        // After capture, show a check mark preview with this success message, instead of a preview of the image.
        Success: {message: "Success!", previewDuration: 0.3},

        // Whether the camera automatically saves the images to the camera roll (iOS) / gallery (Android). Default true.
        StoreImagesToCameraRoll: true,  

        // Whether to allow users to select media from their device (Shows a media button bottom left on the scanner screen).
        UserCanPickMediaFromStorage: true,

        // Whether the next button in the bottom right of the scanner screen goes to the review screen instead of finishing the session.
        ShouldGoToReviewScreenOnFinishPressed: true,

        // The amount of seconds the preview should be visible for, should be a float.
        PreviewDuration: 1.0,
        
        // Optional. Only affects iOS.
        // The warning message when the camera result is too bright.
        ImageTooBrightMessage: "The image is too bright",
       
        // The warning message when the camera result is too dark.
        ImageTooDarkMessage: "The image is too dark",

        // The text inside of the color selection alert dialog button named original.
        ImageColorOriginalText: "original",

        // The text inside of the color selection alert dialog button named grayscale.
        ImageColorGrayscaleText: "grayscale",
  
        // The text inside of the color selection alert dialog button named enhanced.
        ImageColorEnhancedText: "enhanced",
                
        // The amount of opacity for the overlay, should be a float.
        OverlayColorAlpha: 0.75,
         
        // Whether the camera has a view finder overlay (a helper grid so the user knows where the document should be), should be a Boolean.
        IsViewFinderEnabled: true,

        // The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 200).
        ImageMovingSensitivityiOS: 200,
    });
});
```

The result of `KlippaScannerSDK.getCameraResult()` is a Promise, so you can get the result with:
```javascript
KlippaScannerSDK.getCameraResult(options).then((result) => {
    console.log(result);
}).catch((reason) => {
    console.log(reason);
});
```

The content of the result object is:
```
{
  // Whether the MultipleDocuments option was turned on, so you can save it as default.
  "MultipleDocuments": true,

  // Whether the Crop option was turned on, so you can save it as default (Android only).
  "Crop": true,

  // What color option was used, so you can save it as default (Android only).
  "Color": "original",
 
  // An array of images.
  "Images": [
    {
      "Filepath": "/sdcard/scanner/dd0ca979-84e1-426e-8877-586e802fed1f.jpg"
    }
  ]
}
```

The reject reason object has a code and a message, the used codes are:
 - E_ACTIVITY_DOES_NOT_EXIST (Android only)
 - E_FAILED_TO_SHOW_CAMERA (Android only)
 - E_LICENSE_ERROR (on iOS license errors result in E_UNKNOWN_ERROR)
 - E_CANCELED
 - E_UNKNOWN_ERROR

## Specify SDK Version

### Android

Edit the file `android/build.gradle`, add the following:

```maven
allprojects {
  // ... other definitions
  project.ext {
      klippaScannerVersion = "{version}"
  }
}
```

Replace the `{version}` value with the version you want to use.

### iOS

Edit the file `ios/Podfile`, change the pod line of `Klippa-Scanner` and replace `latest.podspec` with `{version}.podspec`, replace the `{version}` value with the version you want to use.

## Customize the colours

### Android

Add or edit the file `android/app/src/main/res/values/colors.xml`, add the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="klippa_scanner_sdk_color_primary">#000000</color>
    <color name="klippa_scanner_sdk_color_accent">#ffffff</color>
    <color name="klippa_scanner_sdk_color_secondary">#2dc36a</color>
    <color name="klippa_scanner_sdk_color_warning_background">#BF000000</color>
    <color name="klippa_scanner_sdk_color_warning_text">#ffffff</color>
    <color name="klippa_scanner_sdk_color_icon_disabled">#444</color>
    <color name="klippa_scanner_sdk_color_icon_enabled">#ffffff</color>
    <color name="klippa_scanner_sdk_color_button_with_icon_foreground">#ffffff</color>
    <color name="klippa_scanner_sdk_color_button_with_icon_background">#444444</color>
    <color name="klippa_scanner_sdk_color_primary_action_foreground">#ffffff</color>
    <color name="klippa_scanner_sdk_color_primary_action_background">#2dc36a</color>
</resources>
```

### iOS

Use the following properties in the config when running `getCameraResult`: `PrimaryColor`, `AccentColor`, `OverlayColor`, `WarningBackgroundColor`, `WarningTextColor`, `OverlayColorAlpha`, `IconDisabledColor`, `IconEnabledColor`,  `ReviewIconColor`, `ButtonWithIconBackgroundColor`, `ButtonWithIconForegroundColor`, `PrimaryActionForegroundColor`, `PrimaryActionBackgroundColor`. Each value should be a string with a `hex` including a `#`, i.e: `#fff` for white.

## Customize the texts

### Android

Add or edit the file `android/app/src/main/res/values/strings.xml`, add the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="klippa_action_crop">Crop</string>
    <string name="klippa_action_delete">Delete</string>
    <string name="klippa_image_color_original">Original</string>
    <string name="klippa_image_color_grayscale">Grayscale</string>
    <string name="klippa_image_color_enhanced">Enhanced</string>

    <string name="klippa_zoom_message">Move closer to the document</string>
    <string name="klippa_image_limit_reached">You have reached the image limit</string>
    <string name="klippa_images">Images</string>
    <string name="klippa_success_message">Success</string>
    <string name="klippa_image_moving_message">Moving too much</string>
    <string name="klippa_orientation_warning_message">Hold your phone in portrait mode</string>

    <string name="klippa_delete_button_text">Delete</string>
    <string name="klippa_retake_button_text">Retake</string>
    <string name="klippa_cancel_button_text">Cancel</string>
    <string name="klippa_cancel_delete_images">Cancel Scanner</string>
    <string name="klippa_cancel_confirmation">When you close the taken scans will be deleted. Are you sure you want to cancel without saving?</string>

    <string name="klippa_continue_button_text">Continue</string>

    <string name="klippa_auto_capture">Auto-Capture</string>
    <string name="klippa_manual_capture">Manual</string>
    <string name="klippa_action_save">Save</string>
    <string name="klippa_action_expand">Expand</string>
    <string name="klippa_action_filter">Filter</string>
    <string name="klippa_action_rotate">Rotate</string>

    <string name="klippa_too_bright_warning_message">The image is too bright</string>
    <string name="klippa_too_dark_warning_message">The image is too dark</string>
</resources>
```

### iOS

Use the following properties in the config when running `getCameraResult`: `ImageTooBrightMessage`, `ImageTooDarkMessage`, `DeleteButtonText`, `RetakeButtonText`, `CancelButtonText`, `CancelAndDeleteImagesButtonText`, `CancelConfirmationMessage`, `MoveCloserMessage`, `ImageMovingMessage`, `ImageLimitReachedMessage`, `OrientationWarningMessage`, `ImageColorOriginalText`, `ImageColorGrayscaleText`, `ImageColorEnhancedText`, `ContinueButtonText`, `SaveCropButtonText`, `ExpandCropButtonText`, `CancelCropButtonText`, `DeleteEditButtonText`, `RotateEditButtonText`, `FilterEditButtonText`, `CropEditButtonText`, `SegmentedModeImageCountMessage`.

## Customize image in CameraMode instructions

### Android

Add an XML file in `android/app/src/res/drawable/` with name `klippa_camera_mode_single_document.xml` to change the image in Single Document Mode.
Add an XML file in `android/app/src/res/drawable/` with name `klippa_camera_mode_multiple_documents.xml` to change the image in Multiple Document Mode.
Add an XML file in `android/app/src/res/drawable/` with name `klippa_camera_mode_segmented_document.xml` to change the image in Segmented Document Mode.

### iOS

Use the following properties in the config:

```ts
// Change the default image in the Single Document Mode instructions.
CameraModeSingle: {name: "Name", message: "Message", image: "{name of image in Assets.xcassets}"}
// Change the default image in the Multi Document Mode instructions.
CameraModeMulti: {name: "Name", message: "Message", image: "{name of image in Assets.xcassets}"}
// Change the default image in the Segmented Document Mode instructions.
CameraModeSegmented: {name: "Name", message: "Message", image: "{name of image in Assets.xcassets}"}
```

## Clear Storage

```javascript
KlippaScannerSDK.purge()
```

## Important iOS notes
Older iOS versions do not ship the Swift libraries. To make sure the SDK works on older iOS versions, you can configure the build to embed the Swift libraries using the build setting `EMBEDDED_CONTENT_CONTAINS_SWIFT = YES`.

We started using XCFrameworks from version 0.1.0, if you want to use that version or up, you need CocoaPod version 1.9.0 or higher.

## Important Android notes
When using a custom trained model for object detection, add the following to your app's build.gradle file to ensure Gradle doesn’t compress the models when building the app:

```
android {
    aaptOptions {
        noCompress "tflite"
    }
}
```

## About Klippa

[Klippa](https://www.klippa.com/en) is a scale-up from [Groningen, The Netherlands](https://goo.gl/maps/CcCGaPTBz3u8noSd6) and was founded in 2015 by six Dutch IT specialists with the goal to digitize paper processes with modern technologies.

We help clients enhance the effectiveness of their organization by using machine learning and OCR. Since 2015 more than a 1000 happy clients have been served with a variety of the software solutions that Klippa offers. Our passion is to help our clients to digitize paper processes by using smart apps, accounts payable software and data extraction by using OCR.

## License

The MIT License (MIT)
