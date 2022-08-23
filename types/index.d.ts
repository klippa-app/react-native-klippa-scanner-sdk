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


export class CameraConfig {
  // Global options.

  // The license as given by Klippa.
  License: string;

  // Whether to show the icon to enable "multi-document-mode"
  AllowMultipleDocuments?: boolean;

  // Whether the "multi-document-mode" should be enabled by default.
  DefaultMultipleDocuments?: boolean;

  // Whether the crop mode (auto edge detection) should be enabled by default.
  DefaultCrop?: boolean;

  // The warning message when someone should move closer to a document, should be a string.
  MoveCloserMessage?: string;

  // The warning message when the camera preview has to much motion to be able to automatically take a photo.
  ImageMovingMessage?: string;

  // The warning message when the camera turned out of portrait mode.
  OrientationWarningMessage?: string;

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

  // Android options.

  // Where to put the image results.
  StoragePath?: string;

  // What the default color conversion will be (original, grayscale, enhanced).
  DefaultColor?: 'original' | 'grayscale' | 'enhanced';

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

  // The text inside of the cancel alert button.
  CancelAndDeleteImagesButtonText?: string;

  // The text inside of the alert to confirm exiting the scanner.
  CancelConfirmationMessage?: string;
  
  // The warning message when the camera result is too bright.
  ImageTooBrightMessage?: string;

  // The warning message when the camera result is too dark.
  ImageTooDarkMessage?: string;

  // The iOS colors to be configured as RGB Hex. For Android see the readme.

  // The primary color of the interface, should be a hex RGB color string.
  PrimaryColor?: string;

  // The accent color of the interface, should be a hex RGB color string.
  AccentColor?: string;

  // The overlay color (when using document detection), should be a hex RGB color string.
  OverlayColor?: string;

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
  ReviewIconColor?: string;

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
  Color?:  'original' | 'grayscale' | 'enhanced';
}

export class CameraResultImage {
  // The path to the image on the filesystem.
  Filepath: string;
}

export class CameraPermissionResult {
  // Android always return Authorized, the SDK itself asks for permission.
  Status: 'Authorized' | 'Denied' | 'Restricted';
}

export declare function getCameraPermission(): Promise<CameraPermissionResult>;
export declare function getCameraResult(config: CameraConfig): Promise<CameraResult>;
