//
//  KlippaScannerSDK.swift
//  KlippaScannerSDK
//
//  Created by Hasan Kucukcayir on 26/10/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import KlippaScanner

@objc(KlippaScannerSDK)
class KlippaScannerSDK: NSObject {

    private var _resolve: RCTPromiseResolveBlock? = nil
    private var _reject: RCTPromiseRejectBlock? = nil

//    MARK: - getCameraPermission
    @objc(withResolver:withRejecter:)
    func getCameraPermission(
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        _resolve = resolve
        _reject = reject


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

}

//    MARK: - KlippaScannerDelegate
extension KlippaScannerSDK: KlippaScannerDelegate {
    func klippaScannerDidFinishScanningWithResult(result: KlippaScanner.KlippaScannerResult) {
        print("success")
    }

    func klippaScannerDidCancel() {
        print("cancel")
    }

    func klippaScannerDidFailWithError(error: Error) {
        print(error)
    }
}

