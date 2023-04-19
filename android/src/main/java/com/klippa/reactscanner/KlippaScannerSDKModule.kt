package com.klippa.reactscanner

import android.Manifest
import android.util.Size
import androidx.core.content.PermissionChecker
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.klippa.scanner.KlippaScannerBuilder
import com.klippa.scanner.KlippaScannerListener
import com.klippa.scanner.model.KlippaImageColor
import com.klippa.scanner.model.KlippaScannerResult

class KlippaScannerSDKModule(
    private val reactContext: ReactApplicationContext
) : ReactContextBaseJavaModule(reactContext) {

    private var mCameraPromise: Promise? = null

    private val klippaScannerListener: KlippaScannerListener = object : KlippaScannerListener {
        override fun klippaScannerDidFinishScanningWithResult(result: KlippaScannerResult) {
            val cameraResult: WritableMap = WritableNativeMap()
            val images: WritableArray = WritableNativeArray()

            val imageList = result.images
            val multipleDocuments = result.multipleDocumentsModeEnabled
            val crop = result.cropEnabled
            val timerEnabled = result.timerEnabled
            val color = result.defaultImageColorLegacy
            cameraResult.putBoolean("MultipleDocuments", multipleDocuments)
            cameraResult.putBoolean("Crop", crop)
            cameraResult.putBoolean("TimerEnabled", timerEnabled)
            cameraResult.putString("Color", color)

            for (image in imageList) {
                val imageMap: WritableMap = WritableNativeMap()
                imageMap.putString("Filepath", image.location)
                images.pushMap(imageMap)
            }
            cameraResult.putArray("Images", images)
            mCameraPromise?.resolve(cameraResult)
        }

        override fun klippaScannerDidFailWithException(exception: Exception) {
            mCameraPromise?.reject(E_LICENSE_ERROR, exception)
        }

        override fun klippaScannerDidCancel() {
            mCameraPromise?.reject(E_CANCELED, "The user canceled")
        }
    }

    override fun getName(): String {
        return "KlippaScannerSDK"
    }

    @ReactMethod
    fun getCameraPermission(promise: Promise) {
        val map: WritableMap = WritableNativeMap()
        val permission = hasRequiredPermissions()
        if (permission) {
            map.putString("Status", "Authorized")
        } else {
            map.putString("Status", "Denied")
        }
        promise.resolve(map)
    }

    private fun hasRequiredPermissions(): Boolean {
        return hasPermission(Manifest.permission.CAMERA)
    }

    private fun hasPermission(permission: String): Boolean {
        return PermissionChecker.checkSelfPermission(
            reactContext,
            permission
        ) == PermissionChecker.PERMISSION_GRANTED
    }

    @ReactMethod
    fun getCameraResult(config: ReadableMap, promise: Promise) {
        val currentActivity = currentActivity
        if (currentActivity == null) {
            promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist")
            mCameraPromise = null
            return
        }

        // Store the promise to resolve/reject when picker returns data
        mCameraPromise = promise
        try {

            val license = config.getString("License")
            if (license.isNullOrEmpty()) {
                promise.reject(E_MISSING_LICENSE, "Missing license")
                return
            }

            val builder = KlippaScannerBuilder(klippaScannerListener, license)

            if (config.hasKey("AllowMultipleDocuments")) {
                builder.menu.allowMultiDocumentsMode = config.getBoolean("AllowMultipleDocuments")
            }

            if (config.hasKey("DefaultMultipleDocuments")) {
                builder.menu.isMultiDocumentsModeEnabled = config.getBoolean("DefaultMultipleDocuments")
            }

            if (config.hasKey("DefaultColor")) {
                when (config.getString("DefaultColor")) {
                    "grayscale" -> builder.colors.imageColorMode = KlippaImageColor.GRAYSCALE
                    "enhanced" -> builder.colors.imageColorMode = KlippaImageColor.ENHANCED
                    else -> builder.colors.imageColorMode = KlippaImageColor.ORIGINAL
                }
            }

            if (config.hasKey("DefaultCrop")) {
                builder.menu.isCropEnabled = config.getBoolean("DefaultCrop")
            }

            if (config.hasKey("StoragePath")) {
                config.getString("StoragePath")?.let {
                    builder.imageAttributes.outputDirectory = it
                }
            }

            if (config.hasKey("OutputFilename")) {
                config.getString("OutputFilename")?.let {
                    builder.imageAttributes.outputFileName = it
                }
            }

            if (config.hasKey("ImageLimit")) {
                builder.imageAttributes.imageLimit = config.getInt("ImageLimit")
            }

            if (config.hasKey("ImageMaxWidth")) {
                builder.imageAttributes.resolutionMaxWidth = config.getInt("ImageMaxWidth")
            }

            if (config.hasKey("ImageMaxHeight")) {
                builder.imageAttributes.resolutionMaxHeight = config.getInt("ImageMaxHeight")
            }

            if (config.hasKey("ImageMaxQuality")) {
                builder.imageAttributes.outputQuality = config.getInt("ImageMaxQuality")
            }

            if (config.hasKey("MoveCloserMessage")) {
                config.getString("MoveCloserMessage")?.let {
                    builder.messages.moveCloserMessage = it
                }
            }

            if (config.hasKey("ImageLimitReachedMessage")) {
                config.getString("ImageLimitReachedMessage")?.let {
                    builder.messages.imageLimitReached = it
                }
            }

            if (config.hasKey("CancelConfirmationMessage")) {
                config.getString("CancelConfirmationMessage")?.let {
                    builder.messages.cancelConfirmationMessage = it
                }
            }

            if (config.hasKey("OrientationWarningMessage")) {
                config.getString("OrientationWarningMessage")?.let {
                    builder.messages.orientationWarningMessage = it
                }
            }

            if (config.hasKey("ImageMovingMessage")) {
                config.getString("ImageMovingMessage")?.let {
                    builder.messages.imageMovingMessage = it
                }
            }

            if (config.hasKey("DeleteButtonText")) {
                config.getString("DeleteButtonText")?.let {
                    builder.buttonTexts.deleteButtonText = it
                }
            }

            if (config.hasKey("RetakeButtonText")) {
                config.getString("RetakeButtonText")?.let {
                    builder.buttonTexts.retakeButtonText = it
                }
            }

            if (config.hasKey("CancelButtonText")) {
                config.getString("CancelButtonText")?.let {
                    builder.buttonTexts.cancelButtonText = it
                }
            }

            if (config.hasKey("CancelAndDeleteImagesButtonText")) {
                config.getString("CancelAndDeleteImagesButtonText")?.let {
                    builder.buttonTexts.cancelAndDeleteImagesButtonText = it
                }
            }


            if (config.hasKey("ShouldGoToReviewScreenWhenImageLimitReached")) {
                builder.menu.shouldGoToReviewScreenWhenImageLimitReached =
                    config.getBoolean("ShouldGoToReviewScreenWhenImageLimitReached")
            }
            if (config.hasKey("UserCanRotateImage")) {
                builder.menu.userCanRotateImage = config.getBoolean("UserCanRotateImage")
            }
            if (config.hasKey("UserCanCropManually")) {
                builder.menu.userCanCropManually = config.getBoolean("UserCanCropManually")
            }
            if (config.hasKey("UserCanChangeColorSetting")) {
                builder.menu.userCanChangeColorSetting = config.getBoolean("UserCanChangeColorSetting")
            }

            if (config.hasKey("Model")) {
                config.getMap("Model")?.let { modelConfig ->
                    val modelName = modelConfig.getString("name")
                    val labelsName = modelConfig.getString("labelsName")
                    if (!modelName.isNullOrEmpty() && !labelsName.isNullOrEmpty()) {
                        builder.objectDetectionModel?.run {
                            this.modelName = modelName
                            modelLabels = labelsName
                            runWithModel = true
                        }
                    }
                }
            }

            if (config.hasKey("Timer")) {
                val timerConfig = config.getMap("Timer") ?: return

                if (timerConfig.hasKey("allowed")) {
                    builder.menu.allowTimer = timerConfig.getBoolean("allowed")
                }

                if (timerConfig.hasKey("enabled")) {
                    builder.menu.isTimerEnabled = timerConfig.getBoolean("enabled")
                }

                if (timerConfig.hasKey("duration")) {
                    builder.durations.timerDuration = timerConfig.getDouble("duration")
                }
            }

            if (config.hasKey("CropPadding")) {
                config.getMap("CropPadding")?.let { cropPaddingConfig ->
                    val width = if (cropPaddingConfig.hasKey("width")) {
                        cropPaddingConfig.getInt("width")
                    } else {
                        builder.imageAttributes.cropPadding.width
                    }

                    val height = if (cropPaddingConfig.hasKey("height")) {
                        cropPaddingConfig.getInt("height")
                    } else {
                        builder.imageAttributes.cropPadding.height
                    }

                    builder.imageAttributes.cropPadding = Size(width, height)
                }
            }

            if (config.hasKey("Success")) {
                val successConfig = config.getMap("Success") ?: return

                if (successConfig.hasKey("message")) {
                    successConfig.getString("message")?.let {
                        builder.messages.successMessage = it
                    }
                }

                if (successConfig.hasKey("previewDuration")) {
                    builder.durations.successPreviewDuration =
                        successConfig.getDouble("previewDuration")
                }
            }

            if (config.hasKey("PreviewDuration")) {
                builder.durations.previewDuration = config.getDouble("PreviewDuration")
            }

            if (config.hasKey("ShutterButton")) {
                val shutterButtonConfig = config.getMap("ShutterButton") ?: return

                if (shutterButtonConfig.hasKey("allowShutterButton")) {
                    builder.shutterButton.allowShutterButton = shutterButtonConfig.getBoolean("allowShutterButton")
                }

                if (shutterButtonConfig.hasKey("hideShutterButton")) {
                    builder.shutterButton.hideShutterButton = shutterButtonConfig.getBoolean("hideShutterButton")
                }
            }

            if (config.hasKey("ImageMovingSensitivityAndroid")) {
                builder.imageAttributes.imageMovingSensitivity =
                    config.getInt("ImageMovingSensitivityAndroid")
            }

            if (config.hasKey("StoreImagesToCameraRoll")) {
                builder.imageAttributes.storeImagesToGallery = config.getBoolean("StoreImagesToCameraRoll")
            }

            val klippaScanner = builder.build(reactContext)
            currentActivity.startActivity(klippaScanner)

        } catch (e: Exception) {
            promise.reject(E_FAILED_TO_SHOW_CAMERA, e)
            mCameraPromise = null
        }
    }

    companion object {
        private const val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"
        private const val E_FAILED_TO_SHOW_CAMERA = "E_FAILED_TO_SHOW_CAMERA"
        private const val E_LICENSE_ERROR = "E_LICENSE_ERROR"
        private const val E_MISSING_LICENSE = "E_MISSING_LICENSE"
        private const val E_CANCELED = "E_CANCELED"
    }
}
