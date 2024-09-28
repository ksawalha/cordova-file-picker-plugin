#import <Cordova/CDVPlugin.h>
#import <UIKit/UIKit.h>

@interface FileSelector : CDVPlugin <UIDocumentPickerDelegate>

@property (nonatomic, strong) NSString *callbackId;

- (void)selectFiles:(CDVInvokedUrlCommand*)command;

@end
