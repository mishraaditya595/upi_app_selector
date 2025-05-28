#import "GetUpiPlugin.h"
#if __has_include(<get_upi/get_upi-Swift.h>)
#import <get_upi/get_upi-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "get_upi-Swift.h"
#endif

@implementation GetUpiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGetUpiPlugin registerWithRegistrar:registrar];
}
@end
