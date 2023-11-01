//
//  KlippaScannerSDK.swift
//  KlippaScannerSDK
//
//  Created by Klippa App BV on 26/10/2023.
//  Copyright © 2020 Klippa App BV. All rights reserved.
//

import KlippaScanner
import AVFoundation

@objc(KlippaScannerSDK)
class KlippaScannerSDK: NSObject {

    private let E_UNKNOWN = "E_UNKNOWN_ERROR"
    private let E_CANCELED = "E_CANCELED"

    private var _resolve: RCTPromiseResolveBlock? = nil
    private var _reject: RCTPromiseRejectBlock? = nil

    private var singleDocumentModeInstructionsDismissed = false
    private var multiDocumentModeInstructionsDismissed = false
    private var segmentedDocumentModeInstructionsDismissed = false

//    MARK: - getCameraPermission
    @objc(withResolver:withRejecter:)
    func getCameraPermission(
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        _resolve = resolve
        _reject = reject

        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch authorizationStatus {
        case .authorized:
            let dict = ["Status": "Authorized"]
            _resolve?(dict)
        case .restricted:
            let errorDescription = KlippaScannerControllerError.restricted.localizedDescription
            let dict = ["Status": errorDescription]
            _resolve?(dict)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                DispatchQueue.main.async { [weak self] in
                    if granted {
                        let dict = ["Status": "Authorized"]
                        self?._resolve?(dict)
                    } else {
                        let dict = ["Status": "Denied"]
                        self?._resolve?(dict)
                    }
                }
            })
        default:
            let errorDescription = KlippaScannerControllerError.authorization.localizedDescription
            let dict = ["Status": errorDescription]
            _resolve?(dict)
        }

    }


//    MARK: - getCameraResult
    @objc(getCameraResult:withResolver:withRejecter:)
    func getCameraResult(
        config: [String: Any],
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        _resolve = resolve
        _reject = reject

        let scannerBuilder = setupScannerBuilder(with: config)

        let result = scannerBuilder.build()

        switch result {
        case .success(let vc):
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            rootViewController?.show(vc, sender: self)
        case .failure(let error):
            print(error.localizedDescription)
        }

    }

    private func setupScannerBuilder(with config: [String: Any]) -> KlippaScannerBuilder {

        let license = config["License"] as? String

        let builder = KlippaScannerBuilder(builderDelegate: self, license: license ?? "")

        if let primaryColor = config["PrimaryColor"] as? UIColor {
            builder.klippaColors.primaryColor = primaryColor
        }

        if let accentColor = config["AccentColor"] as? UIColor {
            builder.klippaColors.accentColor = accentColor
        }

        if let overlayColor = config["OverlayColor"] as? UIColor {
            builder.klippaColors.overlayColor = overlayColor
        }

        if let warningBackgroundColor = config["WarningBackgroundColor"] as? UIColor {
            builder.klippaColors.warningBackgroundColor = warningBackgroundColor
        }

        if let warningTextColor = config["WarningTextColor"] as? UIColor {
            builder.klippaColors.warningTextColor = warningTextColor
        }

        if let overlayColorAlpha = config["OverlayColorAlpha"] as? CGFloat {
            builder.klippaColors.overlayColorAlpha = overlayColorAlpha
        }

        if let iconEnabledColor = config["IconEnabledColor"] as? UIColor {
            builder.klippaColors.iconEnabledColor = iconEnabledColor
        }

        if let iconDisabledColor = config["IconDisabledColor"] as? UIColor {
            builder.klippaColors.iconDisabledColor = iconDisabledColor
        }

        if let reviewIconColor = config["ReviewIconColor"] as? UIColor {
            builder.klippaColors.reviewIconColor = reviewIconColor
        }

        if let defaultImageColor = config["DefaultColor"] as? KlippaImageColor {
            builder.klippaColors.imageColor = defaultImageColor
        }

        if let moveCloserMessage = config["MoveCloserMessage"] as? String {
            builder.klippaMessages.moveCloserMessage = moveCloserMessage
        }

        if let imageTooBrightMessage = config["ImageTooBrightMessage"] as? String {
            builder.klippaMessages.imageTooBrightMessage = imageTooBrightMessage
        }

        if let imageTooDarkMessage = config["ImageTooDarkMessage"] as? String {
            builder.klippaMessages.imageTooDarkMessage = imageTooDarkMessage
        }

        if let imageMovingMessage = config["ImageMovingMessage"] as? String {
            builder.klippaMessages.imageMovingMessage = imageMovingMessage
        }

        if let imageLimitReachedMessage = config["ImageLimitReachedMessage"] as? String {
            builder.klippaMessages.imageLimitReachedMessage = imageLimitReachedMessage
        }

        if let orientationWarningMessage = config["OrientationWarningMessage"] as? String {
            builder.klippaMessages.orientationWarningMessage = orientationWarningMessage
        }

        if let cancelConfirmationMessage = config["CancelConfirmationMessage"] as? String {
            builder.klippaMessages.cancelConfirmationMessage = cancelConfirmationMessage
        }

        if let deleteButtonText = config["DeleteButtonText"] as? String {
            builder.klippaButtonTexts.deleteButtonText = deleteButtonText
        }

        if let retakeButtonText = config["RetakeButtonText"] as? String {
            builder.klippaButtonTexts.retakeButtonText = retakeButtonText
        }

        if let cancelButtonText = config["CancelButtonText"] as? String {
            builder.klippaButtonTexts.cancelButtonText = cancelButtonText
        }

        if let cancelAndDeleteImagesButtonText = config["CancelAndDeleteImagesButtonText"] as? String {
            builder.klippaButtonTexts.cancelAndDeleteImagesButtonText = cancelAndDeleteImagesButtonText
        }

        if let imageColorOriginalText = config["ImageColorOriginalText"] as? String {
            builder.klippaButtonTexts.imageColorOriginalText = imageColorOriginalText
        }

        if let imageColorGrayscaleText = config["ImageColorGrayscaleText"] as? String {
            builder.klippaButtonTexts.imageColorGrayscaleText = imageColorGrayscaleText
        }

        if let imageColorEnhancedText = config["ImageColorEnhancedText"] as? String {
            builder.klippaButtonTexts.imageColorEnhancedText = imageColorEnhancedText
        }

        if let isCropEnabled = config["DefaultCrop"] as? Bool {
            builder.klippaMenu.isCropEnabled = isCropEnabled
        }

        if let timer = config["Timer"] as? [String: Any] {

            if let isTimerEnabled = timer["enabled"] as? Bool {
                builder.klippaMenu.isTimerEnabled = isTimerEnabled
            }

            if let allowTimer = timer["allowed"] as? Bool{
                builder.klippaMenu.allowTimer = allowTimer
            }

            if let timerDuration = timer["duration"] as? Double{
                builder.klippaDurations.timerDuration = timerDuration
            }
        }

        if let userCanRotateImage = config["UserCanRotateImage"] as? Bool {
            builder.klippaMenu.userCanRotateImage = userCanRotateImage
        }

        if let userCanCropManually = config["UserCanCropManually"] as? Bool {
            builder.klippaMenu.userCanCropManually = userCanCropManually
        }

        if let userCanChangeColorSetting = config["UserCanChangeColorSetting "] as? Bool {
            builder.klippaMenu.userCanChangeColorSetting = userCanChangeColorSetting
        }

        if let shouldGoToReviewScreenWhenImageLimitReached = config["ShouldGoToReviewScreenWhenImageLimitReached"] as? Bool {
            builder.klippaMenu.shouldGoToReviewScreenWhenImageLimitReached = shouldGoToReviewScreenWhenImageLimitReached
        }

        if let isViewFinderEnabled = config["IsViewFinderEnabled"] as? Bool {
            builder.klippaMenu.isViewFinderEnabled = isViewFinderEnabled
        }

        if let imageLimit = config["ImageLimit"] as? Int {
            builder.klippaImageAttributes.imageLimit = imageLimit
        }

        if let imageMaxWidth = config["ImageMaxWidth"] as? CGFloat {
            builder.klippaImageAttributes.imageMaxWidth = imageMaxWidth
        }

        if let imageMaxHeight = config["ImageMaxHeight"] as? CGFloat {
            builder.klippaImageAttributes.imageMaxHeight = imageMaxHeight
        }

        if let imageMaxQuality = config["ImageMaxQuality"] as? CGFloat {
            builder.klippaImageAttributes.imageMaxQuality = imageMaxQuality
        }

        if let imageMovingSensitivity = config["ImageMovingSensitivityiOS"] as? CGFloat {
            builder.klippaImageAttributes.imageMovingSensitivity = imageMovingSensitivity
        }

        if let cropPadding = config["CropPadding"] as? [String: CGFloat] {
            if let width = cropPadding["width"], let height = cropPadding["height"] {
                builder.klippaImageAttributes.cropPadding = CGSize(width: width, height: height)
            }
        }

        if let storeImagesToCameraRoll = config["StoreImagesToCameraRoll"] as? Bool {
            builder.klippaImageAttributes.storeImagesToCameraRoll = storeImagesToCameraRoll
        }

        if let shutterButton = config["ShutterButton"] as? [String: Bool] {
            if let allowShutterButton = shutterButton["allowShutterButton"] {
                builder.klippaShutterbutton.allowShutterButton = allowShutterButton
            }

            if let hideShutterButton = shutterButton["hideShutterButton"] {
                builder.klippaShutterbutton.hideShutterButton = hideShutterButton
            }
        }

        if let previewDuration = config["PreviewDuration"] as? Double {
            builder.klippaDurations.previewDuration = previewDuration
        }

        if let successMessage = config["Success"] as? [String: Any] {
            if let successMessage = successMessage["message"] as? String {
                builder.klippaMessages.successMessage = successMessage
            }

            if let previewDuration = successMessage["previewDuration"] as? Double {
                builder.klippaDurations.successPreviewDuration = previewDuration
                builder.klippaDurations.previewDuration = 0
            }
        }

        setBuilderObjectDetectionModel(config, builder)
        setBuilderCameraModes(config, builder)
        
        return builder
    }

    fileprivate func setBuilderObjectDetectionModel(_ config: [String: Any], _ builder: KlippaScannerBuilder) {

        guard let model = config["Model"] as? [String: String] else {
            return
        }

        guard let modelFile = model["modelFile"] else {
            return
        }

        guard let modelLabels = model["modelLabels"] else {
            return
        }

        builder.klippaObjectDetectionModel = KlippaObjectDetectionModel(
            modelFile: modelFile,
            modelLabels: modelLabels
        )

    }

    fileprivate func setBuilderCameraModes(_ config: [String: Any], _ builder: KlippaScannerBuilder) {
        var modes = [KlippaDocumentMode]()

        if let cameraModeSingle = config["CameraModeSingle"] as? [String: Any] {

            let single = KlippaSingleDocumentMode()

            if let name = cameraModeSingle["name"] as? String {
                single.name = name
            }

            let instructions = Instructions(message: "Single Document",
                                            dismissHandler: {
                self.singleDocumentModeInstructionsDismissed = true
            })

            if let message = cameraModeSingle["message"] as? String {
                instructions.message = message
            }

            modes.append(single)
        }

        if let cameraModeMulti = config["CameraModeMulti"] as? [String: Any] {

            let multi = KlippaMultipleDocumentMode()

            if let name = cameraModeMulti["name"] as? String {
                multi.name = name
            }

            let instructions = Instructions(message: "Multiple Documents",
                                            dismissHandler: {
                self.multiDocumentModeInstructionsDismissed = true
            })

            if let message = cameraModeMulti["message"] as? String {
                instructions.message = message
            }

            multi.instructions = instructions

            modes.append(multi)
        }

        if let cameraModeSegmented = config["CameraModeSegmented"] as? [String: Any] {

            let segmented = KlippaSegmentedDocumentMode()

            if let name = cameraModeSegmented["name"] as? String {
                segmented.name = name
            }

            let instructions = Instructions(message: "Segmented Document",
                                            dismissHandler: {
                self.segmentedDocumentModeInstructionsDismissed = true
            })

            if let message = cameraModeSegmented["message"] as? String {
                instructions.message = message
            }

            segmented.instructions = instructions

            modes.append(segmented)
        }

        var index = 0
        if let startingIndex = config["StartingIndex"] as? Int {
            index = startingIndex
        }

        let cameraModes = KlippaCameraModes(
            modes: modes,
            startingIndex: index
        )

        builder.klippaCameraModes = cameraModes
    }

}

//    MARK: - KlippaScannerDelegate
extension KlippaScannerSDK: KlippaScannerDelegate {
    func klippaScannerDidFinishScanningWithResult(result: KlippaScanner.KlippaScannerResult) {

        var images = [Dictionary<String, String>]()
        for image in result.images {

            let path = image.path
            let imageDict = ["Filepath": path]
            images.append(imageDict)
        }

        let cropEnabled = result.cropEnabled
        let timerEnabled = result.timerEnabled

        let resultDict: [String: Any] = ["Images": images,
                                         "Crop": cropEnabled,
                                         "TimerEnabled": timerEnabled,
                                         "SingleDocumentModeInstructionsDismissed": singleDocumentModeInstructionsDismissed,
                                         "MultiDocumentModeInstructionsDismissed": multiDocumentModeInstructionsDismissed,
                                         "SegmentedDocumentModeInstructionsDismissed": segmentedDocumentModeInstructionsDismissed
        ]

        if (_resolve != nil) {
            _resolve?(resultDict)
        }
        _resolve = nil
        _reject = nil
    }

    func klippaScannerDidCancel() {
        if (_reject != nil) {
            _reject?(E_CANCELED, "The user canceled", nil)
        }
        _resolve = nil
        _reject = nil
    }

    func klippaScannerDidFailWithError(error: Error) {
        if (_resolve != nil) {
            _reject?(E_UNKNOWN, "Unknown error", error)
        }
        _resolve = nil
        _reject = nil
    }
}

