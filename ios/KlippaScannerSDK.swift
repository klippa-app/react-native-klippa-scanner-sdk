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

    //  MARK: - getCameraPermission
    @objc func getCameraPermission(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
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


    //  MARK: - getCameraResult
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
            vc.modalPresentationStyle = .fullScreen
            let rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController
            rootViewController?.show(vc, sender: self)
        case .failure(let error):
            if (_reject != nil) {
                _reject?(E_CANCELED, error.localizedDescription, nil)
            }
            _resolve = nil
            _reject = nil
        }

    }
    
    private func setupScannerBuilder(with config: [String: Any]) -> KlippaScannerBuilder {

        let license = config["License"] as? String

        let builder = KlippaScannerBuilder(builderDelegate: self, license: license ?? "")

        if let primaryColor = config["PrimaryColor"] as? String {
            if let color = hexStringToUIColor(hex: primaryColor) {
                builder.klippaColors.primaryColor = color
            }
        }

        if let accentColor = config["AccentColor"] as? String {
            if let color = hexStringToUIColor(hex: accentColor) {
                builder.klippaColors.accentColor = color
            }
        }

        if let secondaryColor = config["SecondaryColor"] as? String {
            if let color = hexStringToUIColor(hex: secondaryColor) {
                builder.klippaColors.secondaryColor = color
            }
        }

        if let warningBackgroundColor = config["WarningBackgroundColor"] as? String {
            if let color = hexStringToUIColor(hex: warningBackgroundColor) {
                builder.klippaColors.warningBackgroundColor = color
            }
        }

        if let warningTextColor = config["WarningTextColor"] as? String {
            if let color = hexStringToUIColor(hex: warningTextColor) {
                builder.klippaColors.warningTextColor = color
            }
        }

        if let overlayColorAlpha = config["OverlayColorAlpha"] as? Double {
            builder.klippaColors.overlayColorAlpha = overlayColorAlpha
        }

        if let iconEnabledColor = config["IconEnabledColor"] as? String {
            if let color = hexStringToUIColor(hex: iconEnabledColor) {
                builder.klippaColors.iconEnabledColor = color
            }
        }

        if let iconDisabledColor = config["IconDisabledColor"] as? String {
            if let color = hexStringToUIColor(hex: iconDisabledColor) {
                builder.klippaColors.iconDisabledColor = color
            }
        }

        if let buttonWithIconForegroundColor = config["ButtonWithIconForegroundColor"] as? String {
            if let color = hexStringToUIColor(hex: buttonWithIconForegroundColor) {
                builder.klippaColors.buttonWithIconForegroundColor = color
            }
        }

        if let buttonWithIconBackgroundColor = config["ButtonWithIconBackgroundColor"] as? String {
            if let color = hexStringToUIColor(hex: buttonWithIconBackgroundColor) {
                builder.klippaColors.buttonWithIconBackgroundColor = color
            }
        }

        if let imageColor = config["DefaultColor"] as? String {
            if(imageColor == "grayscale") {
                builder.klippaColors.imageColor = KlippaImageColor.grayscale
            } else if(imageColor == "enhanced") {
                builder.klippaColors.imageColor = KlippaImageColor.enhanced
            } else {
                builder.klippaColors.imageColor = KlippaImageColor.original
            }
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

        if let segmentedModeImageCountMessage = config["SegmentedModeImageCountMessage"] as? String {
            builder.klippaMessages.segmentedModeImageCountMessage = segmentedModeImageCountMessage
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

        if let cropEditButtonText = config["CropEditButtonText"] as? String {
            builder.klippaButtonTexts.cropEditButtonText = cropEditButtonText
        }

        if let filterEditButtonText = config["FilterEditButtonText"] as? String {
            builder.klippaButtonTexts.filterEditButtonText = filterEditButtonText
        }

        if let rotateEditButtonText = config["RotateEditButtonText"] as? String {
            builder.klippaButtonTexts.rotateEditButtonText = rotateEditButtonText
        }

        if let deleteEditButtonText = config["deleteEditButtonText"] as? String {
            builder.klippaButtonTexts.deleteEditButtonText = deleteEditButtonText
        }

        if let cancelCropButtonText = config["CancelCropButtonText"] as? String {
            builder.klippaButtonTexts.cancelCropButtonText = cancelCropButtonText
        }

        if let expandCropButtonText = config["ExpandCropButtonText"] as? String {
            builder.klippaButtonTexts.expandCropButtonText = expandCropButtonText
        }

        if let saveCropButtonText = config["SaveCropButtonText"] as? String {
            builder.klippaButtonTexts.saveCropButtonText = saveCropButtonText
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

        if let imageMaxWidth = config["ImageMaxWidth"] as? Double {
            builder.klippaImageAttributes.imageMaxWidth = imageMaxWidth
        }

        if let imageMaxHeight = config["ImageMaxHeight"] as? Double {
            builder.klippaImageAttributes.imageMaxHeight = imageMaxHeight
        }

        if let imageMaxQuality = config["ImageMaxQuality"] as? Double {
            builder.klippaImageAttributes.imageMaxQuality = imageMaxQuality
        }

        if let imageMovingSensitivity = config["ImageMovingSensitivityiOS"] as? Double {
            builder.klippaImageAttributes.imageMovingSensitivity = imageMovingSensitivity
        }

        if let cropPadding = config["CropPadding"] as? [String: Double] {
            if let width = cropPadding["width"], let height = cropPadding["height"] {
                builder.klippaImageAttributes.cropPadding = CGSize(width: width, height: height)
            }
        }

        if let storeImagesToCameraRoll = config["StoreImagesToCameraRoll"] as? Bool {
            builder.klippaImageAttributes.storeImagesToCameraRoll = storeImagesToCameraRoll
        }

        if let userCanPickMediaFromStorage = config["UserCanPickMediaFromStorage"] as? Bool {
            builder.klippaMenu.userCanPickMediaFromStorage = userCanPickMediaFromStorage
        }

        if let shouldGoToReviewScreenOnFinishPressed = config["ShouldGoToReviewScreenOnFinishPressed"] as? Bool {
            builder.klippaMenu.shouldGoToReviewScreenOnFinishPressed = shouldGoToReviewScreenOnFinishPressed
        }

        if let brightnessLowerThreshold = config["BrightnessLowerThreshold"] as? Double {
            builder.klippaImageAttributes.brightnessLowerThreshold = brightnessLowerThreshold
        }

        if let brightnessUpperThreshold = config["BrightnessUpperThreshold"] as? Double {
            builder.klippaImageAttributes.brightnessUpperThreshold = brightnessUpperThreshold
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

    private func setBuilderObjectDetectionModel(_ config: [String: Any], _ builder: KlippaScannerBuilder) {

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

    private func setBuilderCameraModes(_ config: [String: Any], _ builder: KlippaScannerBuilder) {
        var modes = [KlippaDocumentMode]()

        if let cameraModeSingle = config["CameraModeSingle"] as? [String: Any] {

            let single = KlippaSingleDocumentMode()

            if let name = cameraModeSingle["name"] as? String {
                single.name = name
            }

            if let message = cameraModeSingle["message"] as? String ?? single.instructions?.message {
                let image = cameraModeSingle["image"] as? String
                single.instructions = Instructions(
                    title: single.name,
                    message: message,
                    image: image ?? KlippaSingleDocumentMode.image
                )
            }

            modes.append(single)
        }

        if let cameraModeMulti = config["CameraModeMulti"] as? [String: Any] {

            let multi = KlippaMultipleDocumentMode()

            if let name = cameraModeMulti["name"] as? String {
                multi.name = name
            }

            if let message = cameraModeMulti["message"] as? String ?? multi.instructions?.message {
                let image = cameraModeMulti["image"] as? String
                multi.instructions = Instructions(
                    title: multi.name,
                    message: message,
                    image: image ?? KlippaMultipleDocumentMode.image
                )
            }

            modes.append(multi)
        }

        if let cameraModeSegmented = config["CameraModeSegmented"] as? [String: Any] {

            let segmented = KlippaSegmentedDocumentMode()

            if let name = cameraModeSegmented["name"] as? String {
                segmented.name = name
            }

            if let message = cameraModeSegmented["message"] as? String ?? segmented.instructions?.message {
                let image = cameraModeSegmented["image"] as? String
                segmented.instructions = Instructions(
                    title: segmented.name,
                    message: message,
                    image: image ?? KlippaSegmentedDocumentMode.image
                )
            }

            modes.append(segmented)
        }

        if modes.isEmpty { return }

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

    private func hexStringToUIColor(hex:String) -> UIColor? {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return nil
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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

        let singleDocumentModeInstructionsDismissed = result.dismissedInstructions[DocModeType.singleDocument.name] ?? false
        let multiDocumentModeInstructionsDismissed = result.dismissedInstructions[DocModeType.multipleDocument.name] ?? false
        let segmentedDocumentModeInstructionsDismissed = result.dismissedInstructions[DocModeType.segmentedDocument.name] ?? false

        let resultDict: [String: Any] = [
            "Images": images,
            "Crop": cropEnabled,
            "TimerEnabled": timerEnabled,
            "SingleDocumentModeInstructionsDismissed": singleDocumentModeInstructionsDismissed,
            "MultiDocumentModeInstructionsDismissed": multiDocumentModeInstructionsDismissed,
            "SegmentedDocumentModeInstructionsDismissed": segmentedDocumentModeInstructionsDismissed
        ]

        _resolve?(resultDict)

        _resolve = nil
        _reject = nil
    }

    func klippaScannerDidCancel() {
        _reject?(E_CANCELED, "The user canceled", nil)
        _resolve = nil
        _reject = nil
    }

    func klippaScannerDidFailWithError(error: Error) {
        _reject?(E_UNKNOWN, "Unknown error", error)
        _resolve = nil
        _reject = nil
    }
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.windows
            .first(where: \.isKeyWindow)
    }
}
