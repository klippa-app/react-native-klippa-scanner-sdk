#import "KlippaScannerSDK.h"
#import <KlippaScanner/KlippaScanner.h>
#import <KlippaScanner/KlippaScanner-Swift.h>
#import <AVFoundation/AVFoundation.h>

@implementation KlippaScannerSDK

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getCameraPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
        @"Authorized", @"Status", nil];
        resolve(dict);
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
        {
            if(granted)
            {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"Authorized", @"Status", nil];
                resolve(dict);
            }
            else
            {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"Denied", @"Status", nil];
                resolve(dict);
            }
        }];
    }
    else if (authStatus == AVAuthorizationStatusRestricted)
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
        @"Restricted", @"Status", nil];
        resolve(dict);
    }
    else
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
        @"Denied", @"Status", nil];
        resolve(dict);
    }
}

RCT_EXPORT_METHOD(getCameraResult:(NSDictionary *)config getCameraResultWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([config objectForKey:@"License"] == nil) {
        return;
    }

    KlippaScannerBuilder *builder = [[KlippaScannerBuilder alloc]initWithBuilderDelegate:self license:[config objectForKey:@"License"]];

    if ([config objectForKey:@"AllowMultipleDocuments"]) {
        builder.klippaMenu.allowMultipleDocumentsMode = [[config objectForKey:@"AllowMultipleDocuments"] boolValue];
    }

    if ([config objectForKey:@"DefaultMultipleDocuments"]) {
        builder.klippaMenu.isMultipleDocumentsModeEnabled = [[config objectForKey:@"DefaultMultipleDocuments"] boolValue];
    }

    if ([config objectForKey:@"DefaultColor"]) {
        NSString *imageColor = [config objectForKey:@"DefaultColor"];

        if([imageColor isEqualToString:@"grayscale"]) {
            builder.klippaColors.imageColor = KlippaImageColorGrayscale;
        } else if([imageColor isEqualToString:@"enhanced"]) {
            builder.klippaColors.imageColor = KlippaImageColorEnhanced;
        } else {
            builder.klippaColors.imageColor = KlippaImageColorOriginal;
        }
    }    

    if ([config objectForKey:@"DefaultCrop"]) {
        builder.klippaMenu.isCropEnabled = [[config objectForKey:@"DefaultCrop"] boolValue];
    }

    if ([config objectForKey:@"ImageMaxWidth"]) {
        builder.klippaImageAttributes.imageMaxWidth = [[config objectForKey:@"ImageMaxWidth"] floatValue];
    }

    if ([config objectForKey:@"ImageMaxHeight"]) {
        builder.klippaImageAttributes.imageMaxHeight = [[config objectForKey:@"ImageMaxHeight"] floatValue];
    }

    if ([config objectForKey:@"ImageMaxQuality"]) {
        builder.klippaImageAttributes.imageMaxQuality = [[config objectForKey:@"ImageMaxQuality"] floatValue];
    }

    if ([config objectForKey:@"MoveCloserMessage"]) {
        builder.klippaMessages.moveCloserMessage = [config objectForKey:@"MoveCloserMessage"];
    }

    if ([config objectForKey:@"ImageTooBrightMessage"]) {
        builder.klippaMessages.imageTooBrightMessage = [config objectForKey:@"ImageTooBrightMessage"];
    }

    if ([config objectForKey:@"ImageTooDarkMessage"]) {
        builder.klippaMessages.imageTooDarkMessage = [config objectForKey:@"ImageTooDarkMessage"];
    }

    if ([config objectForKey:@"ImageLimitReachedMessage"]) {
        builder.klippaMessages.imageLimitReachedMessage = [config objectForKey:@"ImageLimitReachedMessage"];
    } 

    if ([config objectForKey:@"ImageLimit"]) {
        builder.klippaImageAttributes.imageLimit = [[config objectForKey:@"ImageLimit"] intValue];
    }

    if ([config objectForKey:@"ImageMovingMessage"]) {
        builder.klippaMessages.imageMovingMessage = [config objectForKey:@"ImageMovingMessage"];
    }

    if ([config objectForKey:@"DeleteButtonText"]) {
        builder.klippaButtonTexts.deleteButtonText = [config objectForKey:@"DeleteButtonText"];
    }

    if ([config objectForKey:@"RetakeButtonText"]) {
        builder.klippaButtonTexts.retakeButtonText = [config objectForKey:@"RetakeButtonText"];
    }

    if ([config objectForKey:@"CancelButtonText"]) {
        builder.klippaButtonTexts.cancelButtonText = [config objectForKey:@"CancelButtonText"];
    }

    if ([config objectForKey:@"ImageColorOriginalText"]) {
        builder.klippaButtonTexts.imageColorOriginalText = [config objectForKey:@"ImageColorOriginalText"];
    }

    if ([config objectForKey:@"ImageColorGrayscaleText"]) {
        builder.klippaButtonTexts.imageColorGrayscaleText = [config objectForKey:@"ImageColorGrayscaleText"];
    }

    if ([config objectForKey:@"ImageColorEnhancedText"]) {
        builder.klippaButtonTexts.imageColorEnhancedText = [config objectForKey:@"ImageColorEnhancedText"];
    }

    if ([config objectForKey:@"CancelAndDeleteImagesButtonText"]) {
        builder.klippaButtonTexts.cancelAndDeleteImagesButtonText = [config objectForKey:@"CancelAndDeleteImagesButtonText"];
    }

    if ([config objectForKey:@"CancelConfirmationMessage"]) {
        builder.klippaMessages.cancelConfirmationMessage = [config objectForKey:@"CancelConfirmationMessage"];
    }

    if ([config objectForKey:@"OrientationWarningMessage"]) {
        builder.klippaMessages.orientationWarningMessage = [config objectForKey:@"OrientationWarningMessage"];
    }

    if ([config objectForKey:@"ShouldGoToReviewScreenWhenImageLimitReached"]) {
        builder.klippaMenu.shouldGoToReviewScreenWhenImageLimitReached = [[config objectForKey:@"ShouldGoToReviewScreenWhenImageLimitReached"] boolValue];
    }

    if ([config objectForKey:@"UserCanRotateImage"]) {
        builder.klippaMenu.userCanRotateImage = [[config objectForKey:@"UserCanRotateImage"] boolValue];
    }

    if ([config objectForKey:@"UserCanCropManually"]) {
        builder.klippaMenu.userCanCropManually = [[config objectForKey:@"UserCanCropManually"] boolValue];
    }

    if ([config objectForKey:@"UserCanChangeColorSetting"]) {
        builder.klippaMenu.userCanChangeColorSetting = [[config objectForKey:@"UserCanChangeColorSetting"] boolValue];
    }

    if ([config objectForKey:@"PrimaryColor"]) {
        builder.klippaColors.primaryColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"PrimaryColor"]];
    }

    if ([config objectForKey:@"AccentColor"]) {
        builder.klippaColors.accentColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"AccentColor"]];
    }

    if ([config objectForKey:@"OverlayColor"]) {
        builder.klippaColors.overlayColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"OverlayColor"]];
    }

    if ([config objectForKey:@"WarningBackgroundColor"]) {
        builder.klippaColors.warningBackgroundColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"WarningBackgroundColor"]];
    }

    if ([config objectForKey:@"WarningTextColor"]) {
        builder.klippaColors.warningTextColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"WarningTextColor"]];
    }

    if ([config objectForKey:@"OverlayColorAlpha"]) {
        builder.klippaColors.overlayColorAlpha = [[config objectForKey:@"OverlayColorAlpha"] floatValue];
    }

    if ([config objectForKey:@"IconEnabledColor"]) {
        builder.klippaColors.iconEnabledColor = [KlippaScannerSDK colorWithHexString: [config objectForKey:@"IconEnabledColor"]];
    }

    if ([config objectForKey:@"IconDisabledColor"]) {
        builder.klippaColors.iconDisabledColor = [KlippaScannerSDK colorWithHexString: [config objectForKey:@"IconDisabledColor"]];
    }

    if ([config objectForKey:@"ReviewIconColor"]) {
        builder.klippaColors.reviewIconColor = [KlippaScannerSDK colorWithHexString: [config objectForKey:@"ReviewIconColor"]];
    }

    if ([config objectForKey:@"PreviewDuration"]) {
        builder.klippaDurations.previewDuration = [[config objectForKey:@"PreviewDuration"] doubleValue];
    }

    if ([config objectForKey:@"IsViewFinderEnabled"]) {
        builder.klippaMenu.isViewFinderEnabled = [[config objectForKey:@"IsViewFinderEnabled"] boolValue];
    }

    if ([config objectForKey:@"Timer"]) {
        if ([[config objectForKey:@"Timer"] objectForKey:@"allowed"]) {
            builder.klippaMenu.allowTimer = [[[config objectForKey:@"Timer"] objectForKey:@"allowed"] boolValue];
        }
        if ([[config objectForKey:@"Timer"] objectForKey:@"enabled"]) {
            builder.klippaMenu.isTimerEnabled = [[[config objectForKey:@"Timer"] objectForKey:@"enabled"] boolValue];
        }

        if ([[config objectForKey:@"Timer"] objectForKey:@"duration"]) {
            builder.klippaDurations.timerDuration = [[[config objectForKey:@"Timer"] objectForKey:@"duration"] doubleValue];
        }
    }

    if ([config objectForKey:@"CropPadding"]) {
        if ([[config objectForKey:@"CropPadding"] objectForKey:@"width"] && [[config objectForKey:@"CropPadding"] objectForKey:@"height"]) {
            builder.klippaImageAttributes.cropPadding = CGSizeMake([[[config objectForKey:@"CropPadding"] objectForKey:@"width"] floatValue], [[[config objectForKey:@"CropPadding"] objectForKey:@"height"] floatValue]);
        }
    }

    if ([config objectForKey:@"Success"]) {
        if ([[config objectForKey:@"Success"] objectForKey:@"message"]) {
            builder.klippaMessages.successMessage = [[config objectForKey:@"Success"] objectForKey:@"message"];
        }
        if ([[config objectForKey:@"Success"] objectForKey:@"previewDuration"]) {
            builder.klippaDurations.successPreviewDuration = [[[config objectForKey:@"Success"] objectForKey:@"previewDuration"] doubleValue];
            builder.klippaDurations.previewDuration = 0;
        }
    }

    if ([config objectForKey:@"StoreImagesToCameraRoll"]) {
        builder.klippaImageAttributes.storeImagesToCameraRoll = [[config objectForKey:@"StoreImagesToCameraRoll"] boolValue];
    }

    if ([config objectForKey:@"ShutterButton"]) {
        if ([[config objectForKey:@"ShutterButton"] objectForKey:@"allowShutterButton"]) {
            builder.klippaShutterbutton.allowShutterButton = [[[config objectForKey:@"ShutterButton"] objectForKey:@"allowShutterButton"] boolValue];
        }
        if ([[config objectForKey:@"ShutterButton"] objectForKey:@"hideShutterButton"]) {
            builder.klippaShutterbutton.hideShutterButton = [[[config objectForKey:@"ShutterButton"] objectForKey:@"hideShutterButton"] boolValue];
        }
    }

    if ([config objectForKey:@"ImageMovingSensitivityiOS"]) {
        builder.klippaImageAttributes.imageMovingSensitivity = [[config objectForKey:@"ImageMovingSensitivityiOS"] floatValue];
    }

    if ([config objectForKey:@"Model"]) {
        if ([[config objectForKey:@"Model"] objectForKey:@"name"] &&  [[config objectForKey:@"Model"] objectForKey:@"labelsName"]) {
            builder.klippaObjectDetectionModel.modelFile = [[config objectForKey:@"Model"] objectForKey:@"name"];
            builder.klippaObjectDetectionModel.modelLabels = [[config objectForKey:@"Model"] objectForKey:@"labelsName"];
            builder.klippaObjectDetectionModel.runWithModel= YES;
        }
    }

    _resolvePromise = resolve;
    _rejectPromise = reject;

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *viewController  = [builder build];
    [rootViewController presentViewController:viewController animated:true completion:NULL]; 
}

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (void)imageScannerControllerWithDidFailWithError:(NSError * _Nonnull)error {
    if (_resolvePromise != nil) {
        _rejectPromise(@"E_UNKNOWN_ERROR", @"Unknown error", error);
    }
    _resolvePromise = nil;
    _rejectPromise = nil;
}

- (void)imageScannerControllerWithDidFinishScanningWithResult:(ImageScannerResult * _Nonnull)result {
    NSMutableArray *images = [NSMutableArray array];
    if (result.images != nil) {
        for(int i = 0; i < result.images.count; i++) {
            NSDictionary *imageDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       result.images[i].path, @"Filepath", nil];
            [images addObject:imageDict];
        }
    }

    NSNumber *multipleDocuments = [NSNumber numberWithBool:NO];
    if (result.multipleDocumentsModeEnabled) {
        multipleDocuments = [NSNumber numberWithBool:YES];
    }

    NSNumber *cropEnabled = [NSNumber numberWithBool:NO];
    if (result.cropEnabled) {
        cropEnabled = [NSNumber numberWithBool:YES];
    }

    NSNumber *timerEnabled = [NSNumber numberWithBool:NO];
    if (result.timerEnabled) {
        timerEnabled = [NSNumber numberWithBool:YES];
    }

    NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                images, @"Images", 
                                multipleDocuments, @"MultipleDocuments", 
                                cropEnabled, @"Crop", 
                                timerEnabled, @"TimerEnabled", nil];

    if (_resolvePromise != nil) {
        _resolvePromise(resultDict);
    }
    _resolvePromise = nil;
    _rejectPromise = nil;
}

- (void)imageScannerControllerDidCancel {
    if (_rejectPromise != nil) {
        _rejectPromise(@"E_CANCELED", @"The user canceled", nil);
    }
    _resolvePromise = nil;
    _rejectPromise = nil;
}

@end
