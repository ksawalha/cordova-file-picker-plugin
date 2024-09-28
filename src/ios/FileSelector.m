#import "FileSelector.h"
#import <Cordova/CDV.h>

@implementation FileSelector

- (void)selectFiles:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.allowsMultipleSelection = YES;
    [self.viewController presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    
    for (NSURL *url in urls) {
        NSMutableDictionary *fileData = [[NSMutableDictionary alloc] init];
        [fileData setObject:[url lastPathComponent] forKey:@"filename"];
        [fileData setObject:[[url pathExtension] lowercaseString] forKey:@"filemime"];
        [fileData setObject:[url absoluteString] forKey:@"fileUri"];
        [fileArray addObject:fileData];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:fileArray];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end
