package com.klippa.reactscanner

import android.Manifest
import android.app.Activity
import android.content.Intent
import androidx.core.content.PermissionChecker
import com.facebook.react.bridge.BaseActivityEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.klippa.scanner.ScannerFinishedReason
import com.klippa.scanner.ScannerSession
import com.klippa.scanner.ScannerSession.Companion.KLIPPA_ERROR
import com.klippa.scanner.ScannerSession.Companion.KLIPPA_RESULT
import com.klippa.scanner.model.Instructions
import com.klippa.scanner.model.KlippaCameraModes
import com.klippa.scanner.model.KlippaDocumentMode
import com.klippa.scanner.model.KlippaError
import com.klippa.scanner.model.KlippaImageColor
import com.klippa.scanner.model.KlippaMultipleDocumentMode
import com.klippa.scanner.model.KlippaObjectDetectionModel
import com.klippa.scanner.model.KlippaOutputFormat
import com.klippa.scanner.model.KlippaScannerResult
import com.klippa.scanner.model.KlippaSegmentedDocumentMode
import com.klippa.scanner.model.KlippaSingleDocumentMode
import com.klippa.scanner.model.KlippaSize
import com.klippa.scanner.storage.KlippaStorage

class KlippaScannerSDKModule(
    private val reactContext: ReactApplicationContext
) : ReactContextBaseJavaModule(reactContext) {

    companion object {
        private const val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"
        private const val E_FAILED_TO_SHOW_CAMERA = "E_FAILED_TO_SHOW_CAMERA"
        private const val E_MISSING_LICENSE = "E_MISSING_LICENSE"
        private const val E_CANCELED = "E_CANCELED"

        private const val REQUEST_CODE = 99991803
    }

    private var mCameraPromise: Promise? = null


    override fun getName(): String {
        return "KlippaScannerSDK"
    }

    data object UnknownError: KlippaError {
        private fun readResolve(): Any = UnknownError
        override fun message(): String = "Unknown Error"
    }

    private val activityEventListener = object: BaseActivityEventListener() {
        override fun onActivityResult(
            activity: Activity,
            requestCode: Int,
            resultCode: Int,
            data: Intent?
        ) {

            val reason = ScannerFinishedReason.mapResultCode(resultCode)

            when (reason) {
                ScannerFinishedReason.FINISHED -> {
                    val result =
                        data?.serializable<KlippaScannerResult>(KLIPPA_RESULT) ?: kotlin.run {
                            klippaScannerDidFailWithError(UnknownError)
                            return
                        }
                    klippaScannerDidFinishScanningWithResult(result)
                }
                ScannerFinishedReason.ERROR -> {
                    val error =
                        data?.serializable<KlippaError>(KLIPPA_ERROR) ?: kotlin.run {
                            klippaScannerDidFailWithError(UnknownError)
                            return
                        }
                    klippaScannerDidFailWithError(error)
                }
                ScannerFinishedReason.CANCELED -> {
                    klippaScannerDidCancel()
                }
                else -> klippaScannerDidFailWithError(UnknownError)
            }
            super.onActivityResult(activity, requestCode, resultCode, data)
        }
    }

    init {
        reactContext.addActivityEventListener(activityEventListener)
    }

    @ReactMethod
    fun purge(promise: Promise) {
        KlippaStorage.purge(reactContext)
        promise.resolve(null)
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

        val currentActivity = currentActivity ?: kotlin.run {
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

            val scannerSession = ScannerSession(license)

            if (config.hasKey("DefaultColor")) {
                when (config.getString("DefaultColor")) {
                    "grayscale" -> scannerSession.imageAttributes.imageColorMode = KlippaImageColor.GRAYSCALE
                    "enhanced" -> scannerSession.imageAttributes.imageColorMode = KlippaImageColor.ENHANCED
                    "original" -> scannerSession.imageAttributes.imageColorMode = KlippaImageColor.ORIGINAL
                }
            }

            if (config.hasKey("OutputFormat")) {
                when (config.getString("OutputFormat")) {
                    "jpeg" -> {
                        scannerSession.imageAttributes.outputFormat = KlippaOutputFormat.JPEG
                    }
                    "pdfSingle" -> {
                        scannerSession.imageAttributes.outputFormat = KlippaOutputFormat.PDF_SINGLE
                    }
                    "pdfMerged" -> {
                        scannerSession.imageAttributes.outputFormat = KlippaOutputFormat.PDF_MERGED
                    }
                }
            }

            if (config.hasKey("DefaultCrop")) {
                scannerSession.menu.isCropEnabled = config.getBoolean("DefaultCrop")
            }

            if (config.hasKey("StoragePath")) {
                config.getString("StoragePath")?.let {
                    scannerSession.imageAttributes.outputDirectory = it
                }
            }

            if (config.hasKey("OutputFilename")) {
                config.getString("OutputFilename")?.let {
                    scannerSession.imageAttributes.outputFileName = it
                }
            }

            if (config.hasKey("PerformOnDeviceOCR")) {
                scannerSession.imageAttributes.performOnDeviceOCR = config.getBoolean("PerformOnDeviceOCR")
            }
            
            if (config.hasKey("ImageLimit")) {
                scannerSession.imageAttributes.imageLimit = config.getInt("ImageLimit")
            }

            if (config.hasKey("ImageMaxWidth")) {
                scannerSession.imageAttributes.resolutionMaxWidth = config.getInt("ImageMaxWidth")
            }

            if (config.hasKey("ImageMaxHeight")) {
                scannerSession.imageAttributes.resolutionMaxHeight = config.getInt("ImageMaxHeight")
            }

            if (config.hasKey("ImageMaxQuality")) {
                scannerSession.imageAttributes.outputQuality = config.getInt("ImageMaxQuality")
            }

            if (config.hasKey("ShouldGoToReviewScreenWhenImageLimitReached")) {
                scannerSession.menu.shouldGoToReviewScreenWhenImageLimitReached =
                    config.getBoolean("ShouldGoToReviewScreenWhenImageLimitReached")
            }

            if (config.hasKey("UserShouldAcceptResultToContinue")) {
                scannerSession.menu.userShouldAcceptResultToContinue =
                    config.getBoolean("UserShouldAcceptResultToContinue")
            }

            if (config.hasKey("UserCanRotateImage")) {
                scannerSession.menu.userCanRotateImage = config.getBoolean("UserCanRotateImage")
            }

            if (config.hasKey("UserCanCropManually")) {
                scannerSession.menu.userCanCropManually = config.getBoolean("UserCanCropManually")
            }

            if (config.hasKey("UserCanChangeColorSetting")) {
                scannerSession.menu.userCanChangeColorSetting = config.getBoolean("UserCanChangeColorSetting")
            }

            if (config.hasKey("Model")) {
                config.getMap("Model")?.let { modelConfig ->
                    val modelName = modelConfig.getString("name")
                    val labelsName = modelConfig.getString("labelsName")
                    if (!modelName.isNullOrEmpty() && !labelsName.isNullOrEmpty()) {
                        scannerSession.objectDetectionModel =
                            KlippaObjectDetectionModel(
                                modelName = modelName,
                                modelLabels = labelsName
                            )
                    }
                }
            }

            if (config.hasKey("Timer")) {
                val timerConfig = config.getMap("Timer") ?: return

                if (timerConfig.hasKey("allowed")) {
                    scannerSession.menu.allowTimer = timerConfig.getBoolean("allowed")
                }

                if (timerConfig.hasKey("enabled")) {
                    scannerSession.menu.isTimerEnabled = timerConfig.getBoolean("enabled")
                }

                if (timerConfig.hasKey("duration")) {
                    scannerSession.durations.timerDuration = timerConfig.getDouble("duration")
                }
            }

            if (config.hasKey("CropPadding")) {
                config.getMap("CropPadding")?.let { cropPaddingConfig ->
                    val width = if (cropPaddingConfig.hasKey("width")) {
                        cropPaddingConfig.getInt("width")
                    } else {
                        scannerSession.imageAttributes.cropPadding.width
                    }

                    val height = if (cropPaddingConfig.hasKey("height")) {
                        cropPaddingConfig.getInt("height")
                    } else {
                        scannerSession.imageAttributes.cropPadding.height
                    }

                    scannerSession.imageAttributes.cropPadding = KlippaSize(width, height)
                }
            }

            if (config.hasKey("Success")) {
                val successConfig = config.getMap("Success") ?: return

                if (successConfig.hasKey("previewDuration")) {
                    scannerSession.durations.successPreviewDuration =
                        successConfig.getDouble("previewDuration")
                }
            }

            if (config.hasKey("PreviewDuration")) {
                scannerSession.durations.previewDuration = config.getDouble("PreviewDuration")
            }

            if (config.hasKey("ShutterButton")) {
                val shutterButtonConfig = config.getMap("ShutterButton") ?: return

                if (shutterButtonConfig.hasKey("allowShutterButton")) {
                    scannerSession.shutterButton.allowShutterButton = shutterButtonConfig.getBoolean("allowShutterButton")
                }

                if (shutterButtonConfig.hasKey("hideShutterButton")) {
                    scannerSession.shutterButton.hideShutterButton = shutterButtonConfig.getBoolean("hideShutterButton")
                }
            }

            if (config.hasKey("ImageMovingSensitivityAndroid")) {
                scannerSession.imageAttributes.imageMovingSensitivity =
                    config.getInt("ImageMovingSensitivityAndroid")
            }

            if (config.hasKey("StoreImagesToCameraRoll")) {
                scannerSession.imageAttributes.storeImagesToGallery = config.getBoolean("StoreImagesToCameraRoll")
            }

            if (config.hasKey("UserCanPickMediaFromStorage")) {
                scannerSession.menu.userCanPickMediaFromStorage = config.getBoolean("UserCanPickMediaFromStorage")
            }

            if (config.hasKey("ShouldGoToReviewScreenOnFinishPressed")) {
                scannerSession.menu.shouldGoToReviewScreenOnFinishPressed = config.getBoolean("ShouldGoToReviewScreenOnFinishPressed")
            }

            val modes = ArrayList<KlippaDocumentMode>()

            if (config.hasKey("CameraModeSingle")) {
                val cameraModeSingle = config.getMap("CameraModeSingle") ?: return
                val singleCameraMode = KlippaSingleDocumentMode()

                cameraModeSingle.getString("name")?.let {
                    singleCameraMode.name = it
                }

                cameraModeSingle.getString("message")?.let {
                    singleCameraMode.instructions = Instructions(singleCameraMode.name, it)
                }

                modes.add(singleCameraMode)
            }

            if (config.hasKey("CameraModeMulti")) {
                val cameraModeMulti = config.getMap("CameraModeMulti") ?: return

                val multipleCameraMode = KlippaMultipleDocumentMode()

                cameraModeMulti.getString("name")?.let {
                    multipleCameraMode.name = it
                }

                cameraModeMulti.getString("message")?.let {
                    multipleCameraMode.instructions = Instructions(multipleCameraMode.name, it)
                }

                modes.add(multipleCameraMode)
            }

            if (config.hasKey("CameraModeSegmented")) {
                val cameraModeSegmented = config.getMap("CameraModeSegmented") ?: return

                val segmentedCameraMode = KlippaSegmentedDocumentMode()

                cameraModeSegmented.getString("name")?.let {
                    segmentedCameraMode.name = it
                }

                cameraModeSegmented.getString("message")?.let {
                    segmentedCameraMode.instructions = Instructions(segmentedCameraMode.name, it)
                }

                modes.add(segmentedCameraMode)
            }

            if (modes.isNotEmpty()) {
                var index = 0
                if (config.hasKey("StartingIndex")) {
                    index = config.getInt("StartingIndex")
                }

                val cameraModes = KlippaCameraModes(
                    modes = modes,
                    startingIndex = index
                )

                scannerSession.cameraModes = cameraModes
            }

            val intent = scannerSession.getIntent(currentActivity)
            currentActivity.startActivityForResult(intent, REQUEST_CODE)

        } catch (e: Exception) {
            promise.reject(E_FAILED_TO_SHOW_CAMERA, e)
            mCameraPromise = null
        }
    }

    private fun klippaScannerDidFinishScanningWithResult(result: KlippaScannerResult) {
        val cameraResult: WritableMap = WritableNativeMap()
        val images: WritableArray = WritableNativeArray()

        val imageList = result.results
        val crop = result.cropEnabled
        val timerEnabled = result.timerEnabled
        val color = result.defaultImageColorLegacy

        val singleDocumentModeInstructionsDismissed = result.dismissedInstructions["SINGLE_DOCUMENT"] ?: false
        val multiDocumentModeInstructionsDismissed = result.dismissedInstructions["MULTIPLE_DOCUMENT"] ?: false
        val segmentedDocumentModeInstructionsDismissed = result.dismissedInstructions["SEGMENTED_DOCUMENT"] ?: false

        cameraResult.apply {
            putBoolean("Crop", crop)
            putBoolean("TimerEnabled", timerEnabled)
            putString("Color", color)
            putBoolean("SingleDocumentModeInstructionsDismissed", singleDocumentModeInstructionsDismissed)
            putBoolean("MultiDocumentModeInstructionsDismissed", multiDocumentModeInstructionsDismissed)
            putBoolean("SegmentedDocumentModeInstructionsDismissed", segmentedDocumentModeInstructionsDismissed)
        }

        for (image in imageList) {
            val imageMap: WritableMap = WritableNativeMap()
            imageMap.putString("Filepath", image.location)
            images.pushMap(imageMap)
        }
        cameraResult.putArray("Images", images)
        mCameraPromise?.resolve(cameraResult)
    }

    private fun klippaScannerDidFailWithError(error: KlippaError) {
        mCameraPromise?.reject(E_CANCELED, "Scanner was canceled with error: ${error.message()}")
    }

    private fun klippaScannerDidCancel() {
        mCameraPromise?.reject(E_CANCELED, "The user canceled")
    }
}
