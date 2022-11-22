package com.klippa.reactscanner;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;

import com.klippa.scanner.KlippaScannerBuilder;
import com.klippa.scanner.KlippaScannerListener;
import com.klippa.scanner.model.KlippaButtonTexts;
import com.klippa.scanner.model.KlippaColors;
import com.klippa.scanner.model.KlippaDurations;
import com.klippa.scanner.model.KlippaImage;
import com.klippa.scanner.model.KlippaImageAttributes;
import com.klippa.scanner.model.KlippaImageColor;
import com.klippa.scanner.model.KlippaMenu;
import com.klippa.scanner.model.KlippaMessages;
import com.klippa.scanner.model.KlippaObjectDetectionModel;
import com.klippa.scanner.model.KlippaScannerResult;
import com.klippa.scanner.model.KlippaShutterButton;

import android.Manifest;
import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.core.content.PermissionChecker;

import android.util.Size;

import java.util.ArrayList;
import java.util.Objects;

public class KlippaScannerSDKModule extends ReactContextBaseJavaModule {
    private static final String E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST";
    private static final String E_FAILED_TO_SHOW_CAMERA = "E_FAILED_TO_SHOW_CAMERA";
    private static final String E_LICENSE_ERROR = "E_LICENSE_ERROR";
    private static final String E_MISSING_LICENSE= "E_MISSING_LICENSE";
    private static final String E_CANCELED = "E_CANCELED";

    private final ReactApplicationContext reactContext;

    private Promise mCameraPromise;

    private final KlippaScannerListener klippaScannerListener = new KlippaScannerListener() {

        @Override
        public void klippaScannerDidFinishScanningWithResult(@NonNull KlippaScannerResult klippaScannerResult) {
            WritableMap map = new WritableNativeMap();
            WritableArray images = new WritableNativeArray();

            ArrayList<com.klippa.scanner.model.KlippaImage> imageList = (ArrayList<KlippaImage>) klippaScannerResult.getImages();

            boolean multipleDocuments = klippaScannerResult.getMultipleDocumentsModeEnabled();
            boolean crop = klippaScannerResult.getCropEnabled();
            boolean timerEnabled = klippaScannerResult.getTimerEnabled();
            String color = klippaScannerResult.getDefaultImageColorLegacy();

            map.putBoolean("MultipleDocuments", multipleDocuments);
            map.putBoolean("Crop", crop);
            map.putBoolean("TimerEnabled", timerEnabled);
            map.putString("Color", color);

            for (com.klippa.scanner.model.KlippaImage image: imageList) {
                WritableMap imageMap = new WritableNativeMap();
                imageMap.putString("Filepath", image.getLocation());
                images.pushMap(imageMap);
            }

            map.putArray("Images", images);
            mCameraPromise.resolve(map);
        }

        @Override
        public void klippaScannerDidFailWithException(@NonNull Exception e) {
            mCameraPromise.reject(E_LICENSE_ERROR, e);
        }

        @Override
        public void klippaScannerDidCancel() {
            mCameraPromise.reject(E_CANCELED, "The user canceled");
        }
    };

    public KlippaScannerSDKModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "KlippaScannerSDK";
    }

    @ReactMethod
    public void getCameraPermission(final Promise promise) {
        WritableMap map = new WritableNativeMap();
        Boolean permission = hasRequiredPermissions();

        if (permission) {
            map.putString("Status", "Authorized");
        } else {
            map.putString("Status", "Denied");
        }

        promise.resolve(map);
    }

    private Boolean hasRequiredPermissions() {
        return hasPermission(Manifest.permission.CAMERA);
    }

    private Boolean hasPermission(String permission) {
        return PermissionChecker.checkSelfPermission(this.reactContext, permission) == PermissionChecker.PERMISSION_GRANTED;
    }


    @ReactMethod
    public void getCameraResult(final ReadableMap config, final Promise promise) {
        Activity currentActivity = getCurrentActivity();

        if (currentActivity == null) {
            promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist");
            mCameraPromise = null;
            return;
        }

        // Store the promise to resolve/reject when picker returns data
        mCameraPromise = promise;

        try {

            if (!config.hasKey("License")) {
                mCameraPromise.reject(E_MISSING_LICENSE, "Missing license");
                return;
            }

            final KlippaScannerBuilder builder = new KlippaScannerBuilder(klippaScannerListener, config.getString("License"));

            final KlippaColors colors = new KlippaColors();
            final KlippaMenu menu = new KlippaMenu();
            final KlippaImageAttributes imageAttributes = new KlippaImageAttributes();
            final KlippaMessages messages = new KlippaMessages();
            final KlippaButtonTexts buttonTexts = new KlippaButtonTexts();
            final KlippaShutterButton shutterButton = new KlippaShutterButton();
            final KlippaDurations durations = new KlippaDurations();
            final KlippaObjectDetectionModel objectDetectionModel = builder.getObjectDetectionModel();

            if (config.hasKey("AllowMultipleDocuments")) {
                menu.setAllowMultiDocumentsMode(config.getBoolean("AllowMultipleDocuments"));
            }

            if (config.hasKey("DefaultMultipleDocuments")) {
                menu.setMultiDocumentsModeEnabled(config.getBoolean("DefaultMultipleDocuments"));
            }

            if (config.hasKey("DefaultColor")) {
                String imageColor = config.getString("DefaultColor");

                switch (imageColor) {
                    case "grayscale":
                        colors.setImageColorMode(KlippaImageColor.GRAYSCALE);
                        break;
                    case "enhanced":
                        colors.setImageColorMode(KlippaImageColor.ENHANCED);
                        break;
                    default:
                        colors.setImageColorMode(KlippaImageColor.ORIGINAL);
                }
            }

            if (config.hasKey("DefaultCrop")) {
                menu.setCropEnabled(config.getBoolean("DefaultCrop"));
            }

            if (config.hasKey("StoragePath")) {
                imageAttributes.setOutputDirectory(Objects.requireNonNull(config.getString("StoragePath")));
            }

            if (config.hasKey("OutputFilename")) {
                imageAttributes.setOutputFileName(Objects.requireNonNull(config.getString("OutputFilename")));
            }

            if (config.hasKey("ImageLimit")) {
                imageAttributes.setImageLimit(config.getInt("ImageLimit"));
            }

            if (config.hasKey("ImageMaxWidth")) {
                imageAttributes.setResolutionMaxWidth(config.getInt("ImageMaxWidth"));
            }

            if (config.hasKey("ImageMaxHeight")) {
                imageAttributes.setResolutionMaxHeight(config.getInt("ImageMaxHeight"));
            }

            if (config.hasKey("ImageMaxQuality")) {
                imageAttributes.setOutputQuality(config.getInt("ImageMaxQuality"));
            }

            if (config.hasKey("MoveCloserMessage")) {
                messages.setMoveCloserMessage(Objects.requireNonNull(config.getString("MoveCloserMessage")));
            }

            if (config.hasKey("ImageLimitReachedMessage")) {
                messages.setImageLimitReached(Objects.requireNonNull(config.getString("ImageLimitReachedMessage")));
            }

            if (config.hasKey("CancelConfirmationMessage")) {
                messages.setCancelConfirmationMessage(Objects.requireNonNull(config.getString("CancelConfirmationMessage")));
            }

            if (config.hasKey("OrientationWarningMessage")) {
                messages.setOrientationWarningMessage(Objects.requireNonNull(config.getString("OrientationWarningMessage")));
            }

            if (config.hasKey("DeleteButtonText")) {
                buttonTexts.setDeleteButtonText(Objects.requireNonNull(config.getString("DeleteButtonText")));
            }

            if (config.hasKey("RetakeButtonText")) {
                buttonTexts.setRetakeButtonText(Objects.requireNonNull(config.getString("RetakeButtonText")));
            }

            if (config.hasKey("CancelButtonText")) {
                buttonTexts.setCancelButtonText(Objects.requireNonNull(config.getString("CancelButtonText")));
            }

            if (config.hasKey("CancelAndDeleteImagesButtonText")) {
                buttonTexts.setCancelAndDeleteImagesButtonText(Objects.requireNonNull(config.getString("CancelAndDeleteImagesButtonText")));
            }

            if (config.hasKey("ImageMovingMessage")) {
                messages.setImageMovingMessage(Objects.requireNonNull(config.getString("ImageMovingMessage")));
            }

            if (config.hasKey("ShouldGoToReviewScreenWhenImageLimitReached")) {
                menu.setShouldGoToReviewScreenWhenImageLimitReached(config.getBoolean("ShouldGoToReviewScreenWhenImageLimitReached"));
            }

            if (config.hasKey("UserCanRotateImage")) {
                menu.setUserCanRotateImage(config.getBoolean("UserCanRotateImage"));
            }

            if (config.hasKey("UserCanCropManually")) {
                menu.setCropEnabled(config.getBoolean("UserCanCropManually"));
            }

            if (config.hasKey("UserCanChangeColorSetting")) {
                menu.setUserCanRotateImage(config.getBoolean("UserCanChangeColorSetting"));
            }

            if (config.hasKey("Model")) {
                if (config.getMap("Model").hasKey("name")) {
                    assert objectDetectionModel != null;
                    objectDetectionModel.setModelName(config.getMap("Model").getString("name"));
                }
                if (config.getMap("Model").hasKey("labelsName")) {
                    assert objectDetectionModel != null;
                    objectDetectionModel.setModelLabels(config.getMap("Model").getString("labelsName"));
                }
            }

            if (config.hasKey("Timer")) {
                if (config.getMap("Timer").hasKey("allowed")) {
                    menu.setAllowTimer(config.getMap("Timer").getBoolean("allowed"));
                }
                if (config.getMap("Timer").hasKey("enabled")) {
                    menu.setTimerEnabled(config.getMap("Timer").getBoolean("enabled"));
                }
                if (config.getMap("Timer").hasKey("duration")) {
                    durations.setTimerDuration(config.getMap("Timer").getDouble("duration"));
                }
            }

            if (config.hasKey("CropPadding")) {
                if (config.getMap("CropPadding").hasKey("width") && config.getMap("CropPadding").hasKey("height")) {
                    int width = config.getMap("CropPadding").getInt("width");
                    int height = config.getMap("CropPadding").getInt("height");
                    Size size = new Size(width, height);
                    imageAttributes.setCropPadding(size);
                }
            }

            if (config.hasKey("Success")) {
                if (config.getMap("Success").hasKey("message")) {
                    messages.setSuccessMessage(config.getMap("Success").getString("message"));
                }

                if (config.getMap("Success").hasKey("previewDuration")) {
                    durations.setSuccessPreviewDuration(config.getMap("Success").getDouble("previewDuration"));
                }
            }

            if (config.hasKey("PreviewDuration")) {
                durations.setPreviewDuration(config.getDouble("PreviewDuration"));
            }

            if (config.hasKey("ShutterButton")) {
                if (config.getMap("ShutterButton").hasKey("allowShutterButton") && config.getMap("ShutterButton").hasKey("hideShutterButton")) {
                    shutterButton.setAllowShutterButton(config.getMap("ShutterButton").getBoolean("allowShutterButton"));
                    shutterButton.setHideShutterButton(config.getMap("ShutterButton").getBoolean("hideShutterButton"));
                }
            }

            if (config.hasKey("ImageMovingSensitivityAndroid")) {
                imageAttributes.setImageMovingSensitivity(config.getInt("ImageMovingSensitivityAndroid"));
            }

            if (config.hasKey("StoreImagesToCameraRoll")) {
                imageAttributes.setStoreImagesToGallery(config.getBoolean("StoreImagesToCameraRoll"));
            }

            builder.setMenu(menu);
            builder.setButtonTexts(buttonTexts);
            builder.setColors(colors);
            builder.setImageAttributes(imageAttributes);
            builder.setDurations(durations);
            builder.setMessages(messages);
            builder.setShutterButton(shutterButton);
            builder.setObjectDetectionModel(objectDetectionModel);

            currentActivity.startActivity(builder.build(reactContext));
        } catch (Exception e) {
            mCameraPromise.reject(E_FAILED_TO_SHOW_CAMERA, e);
            mCameraPromise = null;
        }
    }
}
