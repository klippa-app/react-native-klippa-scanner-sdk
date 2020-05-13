export class CameraConfig {
  // Global options.

  // The license as given by Klippa.
  License: string;

  // Whether to show the icon to enable "multi-document-mode"
  AllowMultipleDocuments?: boolean;

  // Whether the "multi-document-mode" should be enabled by default.
  DefaultMultipleDocuments?: boolean;

  // Where to put the image results.
  StoragePath?: string;

  // What the default color conversion will be (grayscale, original).
  DefaultColor?: 'original' | 'grayscale';

  // Whether the crop mode (auto edge detection) should be enabled by default.
  DefaultCrop?: boolean;

  // The warning message when someone should move closer to a document, should be a string.
  MoveCloserMessage?: string;

  // Define the max resolution of the output file. It’s possible to set only one of these values.
  // We will make sure the picture fits in the given resolution. We will also keep the aspect ratio of the image.
  // Default is max resolution of camera.

  // The max width of the result image.
  ImageMaxWidth?: number;

  // The max height of the result image.
  ImageMaxHeight?: number;

  // Set the output quality (between 0-100) of the jpg encoder. Default is 100.
  ImageMaxQuality?: number;

  // Android options.

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

  // The primary color of the interface, should be a UIColor.
  PrimaryColor?: any;

  // The accent color of the interface, should be a UIColor.
  AccentColor?: any;

  // The overlay color (when using document detection), should be a UIColor.
  OverlayColor?: any;

  // The color of the background of the warning message, should be a UIColor.
  WarningBackgroundColor?: any;

  // The color of the text of the warning message, should be a UIColor.
  WarningTextColor?: any;

  // The amount of opacity for the overlay, should be a float.
  OverlayColorAlpha?: number;

  // The amount of seconds the preview should be visible for, should be a float.
  PreviewDuration?: number;

  // Whether the scanner automatically cuts out documents, should be a Boolean.
  IsCropEnabled?: boolean;

  // Whether the camera has a view finder overlay (a helper grid so the user knows where the document should be), should be a Boolean.
  IsViewFinderEnabled?: boolean;
}

export class CameraResult {
  // An array of images.
  Images: CameraResultImage[];

  // Whether the MultipleDocuments option was turned on, so you can save it as default.
  MultipleDocuments?: boolean;

  // What color option was used, so you can save it as default.
  Color?: 'original' | 'grayscale';

  // Whether the Crop option was turned on, so you can save it as default.
  Crop?: boolean;
}

export class CameraResultImage {
  // The path to the image on the filesystem.
  Filepath: string;
}

export declare function getCameraResult(config: CameraConfig): Promise<CameraResult>;
