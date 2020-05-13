#import "KlippaScannerSDK.h"

@implementation KlippaScannerSDK

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getCameraResult:(NSDictionary *)config getCameraResultWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  NSDictionary *results = [NSDictionary new];
  resolve(results);
}

@end
