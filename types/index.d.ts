export interface ModelOptions {
  // The name of the model file when using custom object detection.
  name: string;
  // The name of the label file when using custom object detection.
  labelsName: string;
}

export interface TimerOptions {
  // Whether automatically capturing of images is enabled. Only available when using a custom object detection model.
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
  // After capture, show a checkmark preview with this success message, instead of a preview of the image.
  message: string;
  // The amount of seconds the success message should be visible for, should be a float.
  previewDuration: number;
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

  // Android options.

  // Where to put the image results.
  StoragePath?: string;

  // What the default color conversion will be (grayscale, original).
  DefaultColor?: 'original' | 'grayscale';

  // To limit the amount of images that can be taken.
  ImageLimit?: number;

  // The message to display when the limit has been reached.
  ImageLimitReachedMessage?: string;
  OutputFilename?: string;

  // iOS options.

  // The warning message when the camera result is too bright.
  ImageTooBrightMessage?: string;

  // The warning message when the camera result is too dark.
  ImageTooDarkMessage?: string;

  // The iOS colors to be conigured as RGB Hex. For Android see the readme.

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

  // The amount of seconds the preview should be visible for, should be a float.
  PreviewDuration?: number;

  // Whether the camera has a view finder overlay (a helper grid so the user knows where the document should be), should be a Boolean.
  IsViewFinderEnabled?: boolean;

  Model?: ModelOptions;

  Timer?: TimerOptions;

  CropPadding?: Dimensions;

  Success?: SuccessOptions;

  // Whether the camera automatically saves the images to the camera roll. Default true. (iOS version 0.4.2 and up only)
  StoreImagesToCameraRoll?: boolean;
}

export class CameraResult {
  // An array of images.
  Images: CameraResultImage[];

  // Whether the MultipleDocuments option was turned on, so you can save it as default.
  MultipleDocuments?: boolean;

  // Android only.

  // Whether the Crop option was turned on, so you can save it as default.
  Crop?: boolean;

  // What color option was used, so you can save it as default.
  Color?: 'original' | 'grayscale';
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
