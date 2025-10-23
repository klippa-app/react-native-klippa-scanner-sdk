export interface ModelOptions {
  // The name of the model file when using custom object detection.
  name: string;
  // The name of the label file when using custom object detection.
  labelsName: string;
}

export interface TimerOptions {
  // Whether the timerButton is shown or hidden.
  allowed: boolean;
  // Whether automatically capturing of images is enabled.
  enabled: boolean;
  // The duration of the interval (in seconds) in which images are automatically captured, should be a float.
  duration: number;
}

export interface Dimensions {
  // To add extra horizontal padding to the cropped image.
  width: number;
  // To add extra vertical padding to the cropped image.
  height: number;
}

export interface SuccessOptions {
  // After capture, show a check mark preview with this success message, instead of a preview of the image.
  message: string;
  // The amount of seconds the success message should be visible for, should be a float.
  previewDuration: number;
}

export interface ShutterButton {
  // Whether to allow or disallow the shutter button to work (can only be disabled if a model is supplied)
  allowShutterButton: boolean;
  // Whether the shutter button should be hidden (only works if allowShutterButton is false)
  hideShutterButton: boolean;
}

export interface DocumentMode {
  name?: string;
  message?: string;
  image?: string;
}

export class CameraConfig {
  // Global options.

  // The license as given by Klippa.
  License: string;

  // Whether the crop mode (auto edge detection) should be enabled by default.
  DefaultCrop?: boolean;

  // The warning message when someone should move closer to a document, should be a string.
  MoveCloserMessage?: string;

  // The warning message when the camera preview has to much motion to be able to automatically take a photo.
  ImageMovingMessage?: string;

  // The warning message when the camera turned out of portrait mode.
  OrientationWarningMessage?: string;

  // The camera mode for scanning one part documents.
  CameraModeSingle?: DocumentMode;

   // The camera mode for scanning documents that consist of multiple pages.
  CameraModeMulti?: DocumentMode;

  // The camera mode for scanning long documents in separate parts.
  CameraModeSegmented?: DocumentMode;

  // When multiple camera modes are enabled select which should show first by index.
  StartingIndex?: number;

  // Define the max resolution of the output file. It’s possible to set only one of these values.
  // We will make sure the picture fits in the given resolution. We will also keep the aspect ratio of the image.
  // Default is max resolution of camera.

  // The max width of the result image.
  ImageMaxWidth?: number;

  // The max height of the result image.
  ImageMaxHeight?: number;

  // Set the output quality (between 0-100) of the jpg encoder. Default is 100.
  ImageMaxQuality?: number;

  // The amount of seconds the preview should be visible for, should be a float.
  PreviewDuration?: number;

  // Whether to go to the Review Screen once the image limit has been reached. (default false)
  ShouldGoToReviewScreenWhenImageLimitReached?: boolean;

  // Whether to hide or show the rotate button in the Review Screen. (default shown/true)
  UserCanRotateImage?: boolean;

  // Whether to hide or show the cropping button in the Review Screen. (default shown/true)
  UserCanCropManually?: boolean;

  // Whether to hide or show the color changing button in the Review Screen. (default shown/true)
  UserCanChangeColorSetting?: boolean;

  // If you would like to use a custom model for object detection. Model + labels file should be packaged in your bundle.
  Model?: ModelOptions;

  // If you would like to enable automatic capturing of images.
  Timer?: TimerOptions;

  // To add extra horizontal and / or vertical padding to the cropped image.
  CropPadding?: Dimensions;

  // After capture, show a check mark preview with this success message, instead of a preview of the image.
  Success?: SuccessOptions;

  // Whether to disable/hide the shutter button (only works if a model is supplied).
  ShutterButton?: ShutterButton;

  // To limit the amount of images that can be taken.
  ImageLimit?: number;

  // The message to display when the limit has been reached.
  ImageLimitReachedMessage?: string;

  // Whether the camera automatically saves the images to the camera roll (iOS) / gallery (Android). Default true.
  StoreImagesToCameraRoll?: boolean;

  // Whether to allow users to select media from their device (Shows a media button bottom left on the scanner screen).
  UserCanPickMediaFromStorage: boolean;

  // Whether the next button in the bottom right of the scanner screen goes to the review screen instead of finishing the session.
  ShouldGoToReviewScreenOnFinishPressed: boolean;

  // Whether the user must confirm the taken photo before the SDK continues.
  UserShouldAcceptResultToContinue: boolean;

  // What the default color conversion will be (original, grayscale, enhanced, black and white).
  DefaultColor?: 'original' | 'grayscale' | 'enhanced' | 'blackAndWhite';

  // What the output format will be (jpeg, pdfMerged, pdfSingle, png). (Default jpeg)
  OutputFormat?: 'jpeg' | 'pdfMerged' | 'pdfSingle' | 'png';

  // Set the output resolution, uses the DPI to calculate the resolution. (Default OFF)
  // The resulting image will be stretched/compressed to match the set PageFormat.
  // Setting this to anything other than OFF will override `ImageMaxWidth` & `ImageMaxHeight`
  PageFormat?: 'off' | 'a3' | 'a4' | 'a5' | 'a6' | 'b4' | 'b5' | 'letter';

  // The DPI which is used to calculate the PageFormat resolution.
  DPI?: 'auto' | 'dpi200' | 'dpi300';

  // Whether to perform on-device OCR after scanning completes.
  PerformOnDeviceOCR: boolean;

  // The lower threshold before the warning message informs the environment is too dark (default 0).
  BrightnessLowerThreshold: number;

  // The upper threshold before the warning message informs the environment is too bright (default 6).
  BrightnessUpperThreshold: number;

  // Android options.

  // Where to put the image results.
  StoragePath?: string;

  OutputFilename?: string;

  // The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 50).
  ImageMovingSensitivityAndroid?: number;

  // iOS options.

  // The text inside of the delete button.
  DeleteButtonText?: string;

  // The text inside of the retake button.
  RetakeButtonText?: string;

  // The text inside of the cancel button.
  CancelButtonText?: string;

  // The text inside of the color selection alert dialog button named original.
  ImageColorOriginalText?: string;

  // The text inside of the color selection alert dialog button named grayscale.
  ImageColorGrayscaleText?: string;
  
  // The text inside of the color selection alert dialog button named enhanced.
  ImageColorEnhancedText?: string;

  // The text to finish the scanner on the edit screen.
  ContinueButtonText?: string;

  // The text inside of the cancel alert button.
  CancelAndDeleteImagesButtonText?: string;

  // The text inside of the alert to confirm exiting the scanner.
  CancelConfirmationMessage?: string;

  // The text at the top to indicate the picture count on segmented camera mode.
  SegmentedModeImageCountMessage?: string;
  
  // The warning message when the camera result is too bright.
  ImageTooBrightMessage?: string;

  // The warning message when the camera result is too dark.
  ImageTooDarkMessage?: string;

  // The iOS colors to be configured as RGB Hex. For Android see the readme.

  // The primary color of the interface, should be a hex RGB color string.
  PrimaryColor?: string;

  // The accent color of the interface, should be a hex RGB color string.
  AccentColor?: string;

  // The secondary color, should be a hex RGB color string.
  SecondaryColor?: string;

  // The color of the background of the warning message, should be a hex RGB color string.
  WarningBackgroundColor?: string;

  // The color of the text of the warning message, should be a hex RGB color string.
  WarningTextColor?: string;

  // The amount of opacity for the overlay, should be a float.
  OverlayColorAlpha?: number;

  // The color of the menu icons when they are enabled, should be a hex RGB color string.
  IconEnabledColor?: string;

  // The color of the menu icons when they are enabled, should be a hex RGB color string.
  IconDisabledColor?: string;

  // The color of the menu icons of the screen where you can review/edit the images, should be a hex RGB color string.
  ButtonWithIconForegroundColor?: string;

  // The color of the menu icons background of the screen where you can review/edit the images, should be a hex RGB color string.
  ButtonWithIconBackgroundColor?: string;

  // The color of the primary action foreground, should be a hex RGB color string.
  PrimaryActionForegroundColor?: string;

  // The color of the primary action background, should be a hex RGB color string.
  PrimaryActionBackgroundColor?: string;

  // The text below the crop button in the review screen.
  CropEditButtonText?: string;

  // The text below the filter button in the review screen.
  FilterEditButtonText?: string;

  // The text below the rotate button in the review screen.
  RotateEditButtonText?: string;

  // The text below the delete button in the review screen.
  DeleteEditButtonText?: string;

  // The text below the cancel button in the crop screen.
  CancelCropButtonText?: string;

  // The text below the expand button in the crop screen.
  ExpandCropButtonText?: string;

  // The text below the save button in the crop screen.
  SaveCropButtonText?: string;

  // Whether the camera has a view finder overlay (a helper grid so the user knows where the document should be), should be a Boolean.
  IsViewFinderEnabled?: boolean;

  // The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 200).
  ImageMovingSensitivityiOS?: number;
}

export class CameraResult {
  // An array of images.
  Images: CameraResultImage[];

  // Whether the MultipleDocuments option was turned on, so you can save it as default.
  MultipleDocuments?: boolean;

  // Whether the AllowTimer option was turned on, so you can save it as default.
  TimerEnabled?: boolean;

  // Whether the Crop option was turned on, so you can save it as default.
  Crop?: boolean;

  // Android only.

  // What color option was used, so you can save it as default.
  Color?:  'original' | 'grayscale' | 'enhanced' | 'black_and_white';
}

export class CameraResultImage {
  // The path to the image on the filesystem.
  Filepath: string;
}

export class CameraPermissionResult {
  Status: 'Authorized' | 'Denied' | 'Restricted';
}

export declare function getCameraPermission(): Promise<CameraPermissionResult>;
export declare function getCameraResult(config: CameraConfig): Promise<CameraResult>;
export declare function purge(): Promise<void>;