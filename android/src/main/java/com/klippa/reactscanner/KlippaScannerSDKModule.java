package com.klippa.reactscanner;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;

import android.Manifest;
import android.content.Intent;
import android.app.Activity;

import androidx.core.content.PermissionChecker;

import android.util.Log;

import java.util.ArrayList;

public class KlippaScannerSDKModule extends ReactContextBaseJavaModule {
    private static final int CAMERA_REQUEST_CODE = 9193;
    private static final String E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST";
    private static final String E_FAILED_TO_SHOW_CAMERA = "E_FAILED_TO_SHOW_CAMERA";
    private static final String E_LICENSE_ERROR = "E_LICENSE_ERROR";
    private static final String E_CANCELED = "E_CANCELED";
    private static final String E_UNKNOWN_ERROR = "E_UNKNOWN_ERROR";

    private final ReactApplicationContext reactContext;

    private Promise mCameraPromise;

    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent intent) {
            if (requestCode == CAMERA_REQUEST_CODE) {
                if (mCameraPromise != null) {
                    if (resultCode == Activity.RESULT_CANCELED) {
                        if (intent != null && intent.hasExtra(com.klippa.scanner.KlippaScanner.ERROR) && intent.getStringExtra(com.klippa.scanner.KlippaScanner.ERROR) != null) {
                            mCameraPromise.reject(E_LICENSE_ERROR, intent.getStringExtra(com.klippa.scanner.KlippaScanner.ERROR));
                        } else {
                            mCameraPromise.reject(E_CANCELED, "The user canceled");
                        }
                    } else if (resultCode == Activity.RESULT_OK) {
                        WritableMap map = new WritableNativeMap();
                        WritableArray images = new WritableNativeArray();

                        ArrayList<com.klippa.scanner.object.Image> imageList = intent.getParcelableArrayListExtra(com.klippa.scanner.KlippaScanner.IMAGES);
                        boolean multipleDocuments = intent.getBooleanExtra(com.klippa.scanner.KlippaScanner.CREATE_MULTIPLE_RECEIPTS, false);
                        boolean crop = intent.getBooleanExtra(com.klippa.scanner.KlippaScanner.CROP, false);
                        boolean timerEnabled = intent.getBooleanExtra(com.klippa.scanner.KlippaScanner.TIMER_ENABLED, false);
                        String color = intent.getStringExtra(com.klippa.scanner.KlippaScanner.COLOR);

                        map.putBoolean("MultipleDocuments", multipleDocuments);
                        map.putBoolean("Crop", crop);
                        map.putBoolean("TimerEnabled", timerEnabled);
                        map.putString("Color", color);

                        for (int i = 0; i < imageList.size(); i++) {
                            final com.klippa.scanner.object.Image image = imageList.get(i);
                            WritableMap imageMap = new WritableNativeMap();
                            imageMap.putString("Filepath", image.getLocation());
                            images.pushMap(imageMap);
                        }

                        map.putArray("Images", images);
                        mCameraPromise.resolve(map);
                    } else {
                        mCameraPromise.reject(E_UNKNOWN_ERROR, "Unknown error");
                    }

                    mCameraPromise = null;
                }
            }
        }
    };

    public KlippaScannerSDKModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addActivityEventListener(mActivityEventListener);
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
        return hasPermission(Manifest.permission.CAMERA) && hasPermission(Manifest.permission.INTERNET);
    }

    private Boolean hasPermission(String permission) {
        return PermissionChecker.checkSelfPermission(this.reactContext, permission) == PermissionChecker.PERMISSION_GRANTED;
    }


    @ReactMethod
    public void getCameraResult(final ReadableMap config, final Promise promise) {
        Activity currentActivity = getCurrentActivity();

        if (currentActivity == null) {
            promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist");
            return;
        }

        // Store the promise to resolve/reject when picker returns data
        mCameraPromise = promise;

        try {
            final Intent cameraIntent = new Intent(currentActivity, com.klippa.scanner.KlippaScanner.class);

            if (config.hasKey("AllowMultipleDocuments")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.ALLOW_CREATE_MULTIPLE_RECEIPTS, config.getBoolean("AllowMultipleDocuments"));
            }

            if (config.hasKey("DefaultMultipleDocuments")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.DEFAULT_CREATE_MULTIPLE_RECEIPTS, config.getBoolean("DefaultMultipleDocuments"));
            }

            if (config.hasKey("DefaultColor")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.DEFAULT_COLOR, config.getString("DefaultColor"));
            }

            if (config.hasKey("DefaultCrop")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.DEFAULT_CROP, config.getBoolean("DefaultCrop"));
            }

            if (config.hasKey("StoragePath")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.OUTPUT_DIRECTORY, config.getString("StoragePath"));
            }

            if (config.hasKey("OutputFilename")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.OUTPUT_FILENAME, config.getString("OutputFilename"));
            }

            if (config.hasKey("ImageLimit")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.IMAGE_LIMIT, config.getInt("ImageLimit"));
            }

            if (config.hasKey("License")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.LICENSE, config.getString("License"));
            }

            if (config.hasKey("ImageMaxWidth")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.RESOLUTION_MAX_WIDTH, config.getInt("ImageMaxWidth"));
            }

            if (config.hasKey("ImageMaxHeight")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.RESOLUTION_MAX_HEIGHT, config.getInt("ImageMaxHeight"));
            }

            if (config.hasKey("ImageMaxQuality")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.OUTPUT_QUALITY, config.getInt("ImageMaxQuality"));
            }

            if (config.hasKey("MoveCloserMessage")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.MOVE_CLOSER_MESSAGE, config.getString("MoveCloserMessage"));
            }

            if (config.hasKey("ImageLimitReachedMessage")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.IMAGE_LIMIT_REACHED_MESSAGE, config.getString("ImageLimitReachedMessage"));
            }

            if (config.hasKey("ImageMovingMessage")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.IMAGE_MOVING_MESSAGE, config.getString("ImageMovingMessage"));
            }

            if (config.hasKey("Model")) {
                if (config.getMap("Model").hasKey("name")) {
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.MODEL_NAME, config.getMap("Model").getString("name"));
                }
                if (config.getMap("Model").hasKey("labelsName")) {
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.MODEL_LABELS_NAME, config.getMap("Model").getString("labelsName"));
                }
            }

            if (config.hasKey("Timer")) {
                if (config.getMap("Timer").hasKey("allowed")) {
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.ALLOW_TIMER, config.getMap("Timer").getBoolean("allowed"));
                }
                if (config.getMap("Timer").hasKey("enabled")) {
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.TIMER_ENABLED, config.getMap("Timer").getBoolean("enabled"));
                }
                if (config.getMap("Timer").hasKey("duration")) {
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.TIMER_DURATION, config.getMap("Timer").getDouble("duration"));
                }
            }

            if (config.hasKey("CropPadding")) {
                if (config.getMap("CropPadding").hasKey("width") && config.getMap("CropPadding").hasKey("height")) {
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.CROP_PADDING_WIDTH, config.getMap("CropPadding").getInt("width"));
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.CROP_PADDING_HEIGHT, config.getMap("CropPadding").getInt("height"));
                }
            }

            if (config.hasKey("Success")) {
                if (config.getMap("Success").hasKey("message")) {
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.SUCCESS_MESSAGE, config.getMap("Success").getString("message"));
                }

                if (config.getMap("Success").hasKey("previewDuration")) {
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.SUCCESS_PREVIEW_DURATION, config.getMap("Success").getDouble("previewDuration"));
                }
            }

            if (config.hasKey("PreviewDuration")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.PREVIEW_DURATION, config.getDouble("PreviewDuration"));
            }

            if (config.hasKey("ShutterButton")) {
                if (config.getMap("ShutterButton").hasKey("allowShutterButton") && config.getMap("ShutterButton").hasKey("hideShutterButton")) {
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.ALLOW_SHUTTER_BUTTON, config.getMap("ShutterButton").getBoolean("allowShutterButton"));
                    cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.HIDE_SHUTTER_BUTTON, config.getMap("ShutterButton").getBoolean("hideShutterButton"));
                }
            }

            if (config.hasKey("ImageMovingSensitivityAndroid")) {
                cameraIntent.putExtra(com.klippa.scanner.KlippaScanner.IMAGE_MOVING_SENSITIVITY, config.getInt("ImageMovingSensitivityAndroid"));
            }

            currentActivity.startActivityForResult(cameraIntent, CAMERA_REQUEST_CODE);
        } catch (Exception e) {
            mCameraPromise.reject(E_FAILED_TO_SHOW_CAMERA, e);
            mCameraPromise = null;
        }
    }
}
