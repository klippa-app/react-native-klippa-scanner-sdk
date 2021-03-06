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
    if ([config objectForKey:@"License"]) {
        KlippaScanner.setup.license = [config objectForKey:@"License"];
    } else {
        KlippaScanner.setup.license = @"";
    }

    if ([config objectForKey:@"AllowMultipleDocuments"]) {
        KlippaScanner.setup.allowMultipleDocumentsMode = [[config objectForKey:@"AllowMultipleDocuments"] boolValue];
    } else {
        KlippaScanner.setup.allowMultipleDocumentsMode = YES;
    }

    if ([config objectForKey:@"DefaultMultipleDocuments"]) {
        KlippaScanner.setup.isMultipleDocumentsModeEnabled = [[config objectForKey:@"DefaultMultipleDocuments"] boolValue];
    } else {
        KlippaScanner.setup.isMultipleDocumentsModeEnabled = NO;
    }

    if ([config objectForKey:@"DefaultCrop"]) {
        KlippaScanner.setup.isCropEnabled = [[config objectForKey:@"DefaultCrop"] boolValue];
    } else {
        KlippaScanner.setup.isCropEnabled = YES;
    }

    if ([config objectForKey:@"ImageMaxWidth"]) {
        KlippaScanner.setup.imageMaxWidth = [[config objectForKey:@"ImageMaxWidth"] floatValue];
    } else {
        KlippaScanner.setup.imageMaxWidth = 0;
    }

    if ([config objectForKey:@"ImageMaxHeight"]) {
        KlippaScanner.setup.imageMaxHeight = [[config objectForKey:@"ImageMaxHeight"] floatValue];
    } else {
        KlippaScanner.setup.imageMaxHeight = 0;
    }

    if ([config objectForKey:@"ImageMaxQuality"]) {
        KlippaScanner.setup.imageMaxQuality = [[config objectForKey:@"ImageMaxQuality"] floatValue];
    } else {
        KlippaScanner.setup.imageMaxQuality = 100;
    }

    if ([config objectForKey:@"MoveCloserMessage"]) {
        KlippaScanner.setup.moveCloserMessage = [config objectForKey:@"MoveCloserMessage"];
    } else {
        KlippaScanner.setup.moveCloserMessage = @"";
    }

    if ([config objectForKey:@"ImageTooBrightMessage"]) {
        KlippaScanner.setup.imageTooBrightMessage = [config objectForKey:@"ImageTooBrightMessage"];
    } else {
        KlippaScanner.setup.imageTooBrightMessage = @"";
    }

    if ([config objectForKey:@"ImageTooDarkMessage"]) {
        KlippaScanner.setup.imageTooDarkMessage = [config objectForKey:@"ImageTooDarkMessage"];
    } else {
        KlippaScanner.setup.imageTooDarkMessage = @"";
    }

    if ([config objectForKey:@"ImageMovingMessage"]) {
        KlippaScanner.setup.imageMovingMessage = [config objectForKey:@"ImageMovingMessage"];
    } else {
        KlippaScanner.setup.imageMovingMessage = @"";
    }

    if ([config objectForKey:@"PrimaryColor"]) {
        KlippaScanner.setup.primaryColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"PrimaryColor"]];
    } else {
        KlippaScanner.setup.primaryColor = [UIColor colorWithRed:0.153 green:0.733  blue:0.373 alpha:1.0];
    }

    if ([config objectForKey:@"AccentColor"]) {
        KlippaScanner.setup.accentColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"AccentColor"]];
    } else {
        KlippaScanner.setup.accentColor = [UIColor colorWithRed:0.153 green:0.733 blue:0.373 alpha:1.0];
    }

    if ([config objectForKey:@"OverlayColor"]) {
        KlippaScanner.setup.overlayColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"OverlayColor"]];
    } else {
        KlippaScanner.setup.overlayColor = [UIColor colorWithRed:0.153 green:0.733 blue:0.373 alpha:1.0];
    }

    if ([config objectForKey:@"WarningBackgroundColor"]) {
        KlippaScanner.setup.warningBackgroundColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"WarningBackgroundColor"]];
    } else {
        KlippaScanner.setup.warningBackgroundColor = UIColor.systemRedColor;
    }

    if ([config objectForKey:@"WarningTextColor"]) {
        KlippaScanner.setup.warningTextColor = [KlippaScannerSDK colorWithHexString:[config objectForKey:@"WarningTextColor"]];
    } else {
        KlippaScanner.setup.warningTextColor = UIColor.whiteColor;
    }

    if ([config objectForKey:@"OverlayColorAlpha"]) {
        KlippaScanner.setup.overlayColorAlpha = [[config objectForKey:@"OverlayColorAlpha"] floatValue];
    } else {
        KlippaScanner.setup.overlayColorAlpha = 0.7;
    }

    if ([config objectForKey:@"IconEnabledColor"]) {
        KlippaScanner.setup.iconEnabledColor = [KlippaScannerSDK colorWithHexString: [config objectForKey:@"IconEnabledColor"]];
    } else {
        KlippaScanner.setup.iconEnabledColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 1.0];
    }

    if ([config objectForKey:@"IconDisabledColor"]) {
        KlippaScanner.setup.iconDisabledColor = [KlippaScannerSDK colorWithHexString: [config objectForKey:@"IconDisabledColor"]];
    } else {
        KlippaScanner.setup.iconDisabledColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.5];
    }

    if ([config objectForKey:@"ReviewIconColor"]) {
        KlippaScanner.setup.reviewIconColor = [KlippaScannerSDK colorWithHexString: [config objectForKey:@"ReviewIconColor"]];
    } else {
        KlippaScanner.setup.reviewIconColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 1.0];
    }

    if ([config objectForKey:@"PreviewDuration"]) {
        KlippaScanner.setup.previewDuration = [[config objectForKey:@"PreviewDuration"] doubleValue];
    } else {
        KlippaScanner.setup.previewDuration = 1;
    }

    if ([config objectForKey:@"IsViewFinderEnabled"]) {
        KlippaScanner.setup.isViewFinderEnabled = [[config objectForKey:@"IsViewFinderEnabled"] boolValue];
    } else {
        KlippaScanner.setup.isViewFinderEnabled = NO;
    }

    if ([config objectForKey:@"Timer"]) {
        if ([[config objectForKey:@"Timer"] objectForKey:@"enabled"]) {
            KlippaScanner.setup.isTimerEnabled = [[[config objectForKey:@"Timer"] objectForKey:@"enabled"] boolValue];
        }

        if ([[config objectForKey:@"Timer"] objectForKey:@"duration"]) {
            KlippaScanner.setup.timerDuration = [[[config objectForKey:@"Timer"] objectForKey:@"duration"] doubleValue];
        }
    }

    if ([config objectForKey:@"CropPadding"]) {
        if ([[config objectForKey:@"CropPadding"] objectForKey:@"width"] && [[config objectForKey:@"CropPadding"] objectForKey:@"height"]) {
            KlippaScanner.setup.cropPadding = CGSizeMake([[[config objectForKey:@"CropPadding"] objectForKey:@"width"] floatValue], [[[config objectForKey:@"CropPadding"] objectForKey:@"height"] floatValue]);
        }
    }

    if ([config objectForKey:@"Success"]) {
        if ([[config objectForKey:@"Success"] objectForKey:@"message"]) {
            KlippaScanner.setup.successMessage = [[config objectForKey:@"Success"] objectForKey:@"message"];
        }
        if ([[config objectForKey:@"Success"] objectForKey:@"previewDuration"]) {
            KlippaScanner.setup.successPreviewDuration = [[[config objectForKey:@"Success"] objectForKey:@"previewDuration"] doubleValue];
            KlippaScanner.setup.previewDuration = 0;
        }
    }

    if ([config objectForKey:@"StoreImagesToCameraRoll"]) {
        KlippaScanner.setup.storeImagesToCameraRoll = [[config objectForKey:@"StoreImagesToCameraRoll"] boolValue];
    } else {
        KlippaScanner.setup.storeImagesToCameraRoll = YES;
    }

    if ([config objectForKey:@"ShutterButton"]) {
        if ([[config objectForKey:@"ShutterButton"] objectForKey:@"allowShutterButton"]) {
            KlippaScanner.setup.allowShutterButton = [[[config objectForKey:@"ShutterButton"] objectForKey:@"allowShutterButton"] boolValue];
        }
        if ([[config objectForKey:@"ShutterButton"] objectForKey:@"hideShutterButton"]) {
            KlippaScanner.setup.hideShutterButton = [[[config objectForKey:@"ShutterButton"] objectForKey:@"hideShutterButton"] boolValue];
        }
    }

    if ([config objectForKey:@"ImageMovingSensitivityiOS"]) {
        KlippaScanner.setup.ImageMovingSensitivity = [[config objectForKey:@"ImageMovingSensitivityiOS"] floatValue];
    }

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;

    if ([config objectForKey:@"Model"]) {
        if ([[config objectForKey:@"Model"] objectForKey:@"name"]) {
            KlippaScanner.setup.modelFile = [[config objectForKey:@"Model"] objectForKey:@"name"];
        }
        if ([[config objectForKey:@"Model"] objectForKey:@"labelsName"]) {
            KlippaScanner.setup.modelLabels = [[config objectForKey:@"Model"] objectForKey:@"labelsName"];
        }
        KlippaScanner.setup.modelViewController = rootViewController;
        KlippaScanner.setup.runWithModel = YES;
    }

    _resolvePromise = resolve;
    _rejectPromise = reject;

    ImageScannerController *imageScannerController  = [[ImageScannerController alloc] init];

    imageScannerController.imageScannerDelegate = self;
    imageScannerController.modalPresentationStyle = UIModalPresentationFullScreen;

    [rootViewController presentViewController:imageScannerController animated:true completion:NULL];
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

- (void)imageScannerController:(ImageScannerController * _Nonnull)scanner didFailWithError:(NSError * _Nonnull)error {
    if (_resolvePromise != nil) {
        _rejectPromise(@"E_UNKNOWN_ERROR", @"Unknown error", error);
    }
    _resolvePromise = nil;
    _rejectPromise = nil;
    [scanner dismissViewControllerAnimated:true completion:nil];
}

- (void)imageScannerController:(ImageScannerController * _Nonnull)scanner didFinishScanningWithResult:(ImageScannerResult * _Nonnull)result {
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

    NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                images, @"Images", multipleDocuments, @"MultipleDocuments", nil];

    if (_resolvePromise != nil) {
        _resolvePromise(resultDict);
    }
    _resolvePromise = nil;
    _rejectPromise = nil;
}

- (void)imageScannerControllerDidCancel:(ImageScannerController * _Nonnull)scanner {
    if (_rejectPromise != nil) {
        _rejectPromise(@"E_CANCELED", @"The user canceled", nil);
    }
    _resolvePromise = nil;
    _rejectPromise = nil;
}

@end
