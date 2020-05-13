#import <React/RCTBridgeModule.h>
#import <KlippaScanner/KlippaScanner.h>
#import <KlippaScanner/KlippaScanner-Swift.h>

@interface KlippaScannerSDK : NSObject <RCTBridgeModule, ImageScannerControllerDelegate>
@property(nullable) RCTPromiseResolveBlock resolvePromise;
@property(nullable) RCTPromiseRejectBlock rejectPromise;

+ (UIColor *_Nonnull) colorWithHexString: (NSString *_Nonnull) hexString;
+ (CGFloat) colorComponentFrom: (NSString *_Nonnull) string start: (NSUInteger) start length: (NSUInteger) length;
@end
