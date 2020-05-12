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

import android.content.Intent;
import android.app.Activity;

import java.util.ArrayList;

public class KlippaScannerSDKModule extends ReactContextBaseJavaModule {
    private static final int CAMERA_REQUEST_CODE = 9193;
    private static final String E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST";
    private static final String E_FAILED_TO_SHOW_CAMERA = "E_FAILED_TO_SHOW_CAMERA";
    private static final String E_LICENSE_ERROR = "E_LICENSE_ERROR";
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
                            return;
                        }
                        mCameraPromise.resolve("1");
                    } else if (resultCode == Activity.RESULT_OK) {
                        WritableMap map = new WritableNativeMap();
                        WritableArray images = new WritableNativeArray();

                        ArrayList<com.klippa.scanner.object.Image> imageList = intent.getParcelableArrayListExtra(com.klippa.scanner.KlippaScanner.IMAGES);
                        boolean multipleDocuments = intent.getBooleanExtra(com.klippa.scanner.KlippaScanner.CREATE_MULTIPLE_RECEIPTS, false);
                        boolean crop = intent.getBooleanExtra(com.klippa.scanner.KlippaScanner.CROP, false);
                        String color = intent.getStringExtra(com.klippa.scanner.KlippaScanner.COLOR);

                        map.putBoolean("MultipleDocuments", multipleDocuments);
                        map.putBoolean("Crop", crop);
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
                        mCameraPromise.reject(E_UNKNOWN_ERROR);
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

            currentActivity.startActivityForResult(cameraIntent, CAMERA_REQUEST_CODE);
        } catch (Exception e) {
            mCameraPromise.reject(E_FAILED_TO_SHOW_CAMERA, e.toString());
            mCameraPromise = null;
        }
    }
}
