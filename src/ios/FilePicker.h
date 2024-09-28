#import <Cordova/CDV.h>

@interface FilePicker : CDVPlugin <UIDocumentPickerDelegate>
@property (nonatomic, strong) NSString* callbackId;
- (void)selectFiles:(CDVInvokedUrlCommand*)command;
@end
