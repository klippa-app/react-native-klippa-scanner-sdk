## 1.0.7

* Fixed issue where `purge()` implementation was missing on iOS.

## 1.0.6

* Added `ContinueButtonText` to change the text on the finish screen for iOS.

## 1.0.5

* Bumped Android to 4.0.10
* Bumped iOS to 2.0.9

## 1.0.4

* Bumped iOS to 2.0.7

## 1.0.3

* Bumped Android to 4.0.8
* Bumped iOS to 2.0.6
* Added method `purge()`.
* Added setup options `PerformOnDeviceOCR` and `OutputFormat`.

## 1.0.2

* Bumped Android to 4.0.6
* Bumped iOS to 2.0.5
* Added `UserShouldAcceptResultToContinue`.

## 1.0.1

* Bumped Android to 4.0.5
* Bumped iOS to 2.0.4
* Added `UserCanPickMediaFromStorage` and `ShouldGoToReviewScreenOnFinishPressed`.
* Added `BrightnessLowerThreshold` and `BrightnessUpperThreshold` for iOS.

## 1.0.0

**NOTE:** This version introduces breaking changes, please see our documentation for the new implementation.

* Bump Android to 4.0.1
* Bump iOS to 2.0.2
* Replaced `ReviewIconColor` with `ButtonWithIconForeground` and `ButtonWithIconBackground`.
* Renamed `OverlayColor` to `SecondaryColor`
* Added `SegmentedModeImageCountMessage`, `CropEditButtonText`, `FilterEditButtonText`, `RotateEditButtonText`, `DeleteEditButtonText` `CancelCropButtonText`, `ExpandCropButtonText` and `SaveCropButtonText` for iOS.
* All messages, texts and colors must now be set through `XML` on Android.
* Bumped minimum iOS version to `14.0`.
* Bumped minimum Android version to `25`.

## 0.4.3

* Bump Android to 3.1.8
* Bump iOS to 1.2.2

## 0.4.2

* Bump Android to 3.1.4
* Bump iOS to 1.2.1

## 0.4.1

* Fixed issue where `getCameraPermission()` was not being handled correctly on iOS.
* Fixed issue where some colors were not being set on iOS.

## 0.4.0

* Bump iOS to 1.2.0
* Bump Android to 3.1.1
* Removed `AllowMultipleDocuments` and `DefaultMultipleDocuments`. 
* Added built-in camera modes: `CameraModeSingle`, `CameraModeMulti`, `CameraModeSegmented`.

## 0.3.3

* Bump iOS to 1.1.0
* Added the ability to now reference the iOS SDK pod. See the [README](https://github.com/klippa-app/react-native-klippa-scanner-sdk#ios) for more information.


## 0.3.2

* Bump Android to 3.0.3

## 0.3.1

* Bump Android to 3.0.2

## 0.3.0

* Bump iOS to 1.0.0
* Bump Android to 3.0.1
* Changed iOS deployment target from 11.0 to 13.0.
* Converted Java to Kotlin for Android SDK.

## 0.2.14

* Bump Android to 2.1.11

## 0.2.13

* Bump Android to 2.1.10

## 0.2.12

* Bump Android to 2.1.9
* Bump iOS to 0.5.4
* Bump Android compile and target SDK version to 33.

## 0.2.11

* Renamed `DefaultImageColor` to `DefaultColor` for iOS. (Android and iOS now use the same naming).

## 0.2.10

* Bump iOS to 0.5.3

## 0.2.9

* Bump Android to 2.1.7
* Now use default values supplied by native scanner if no value is provided.

## 0.2.8

* Added support from React 16 until React 19.
* Bump Android to 2.1.6

## 0.2.7

* Bump Android to 2.1.5
* Bump iOS to 0.5.2
* Added support for RN 0.69+

## 0.2.6

* Bump Android to 2.1.4

## 0.2.5

* Bump Android to 2.1.3

## 0.2.4

* Bump Android to 2.1.2
* Bump iOS to 0.5.1

## 0.2.3

* Bump Android to 2.1.1

## 0.2.2

* Bump Android to 2.1.0
* Bump iOS to 0.5.0

## 0.2.1

* Bump Android to 2.0.8
* Bump iOS to 0.4.12

## 0.2.0

* Added support for gradle 7+

## 0.1.13

* Bump iOS to 0.4.11

## 0.1.12

* Bump Android to 2.0.7

## 0.1.11

* Fixed issue with permission checking on Android

## 0.1.10

* Bump Android to 2.0.6
* Bump iOS to 0.4.10

## 0.1.9

* Bump Android to 2.0.3
* Bump iOS to 0.4.6

## 0.1.8

* Bump Android to 2.0.2
* Bump iOS to 0.4.5

## 0.1.7

* Bump Android to 1.3.7
* Bump iOS to 0.4.3
