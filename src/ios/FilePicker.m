#import "FilePicker.h"
#import <Cordova/CDV.h>

@implementation FilePicker

- (void)selectFiles:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    NSArray *types = @[@"public.data"];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.allowsMultipleSelection = YES;

    [self.viewController presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSMutableArray *resultArray = [NSMutableArray array];

    for (NSURL *url in urls) {
        NSMutableDictionary *fileData = [NSMutableDictionary dictionary];
        NSString *filename = [url lastPathComponent];
        NSString *mimeType = [self mimeTypeForPath:url];
        [fileData setObject:filename forKey:@"filename"];
        [fileData setObject:mimeType forKey:@"filemime"];
        [fileData setObject:url.absoluteString forKey:@"filepath"]; // URI to access the file
        [resultArray addObject:fileData];
    }

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:resultArray];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (NSString *)mimeTypeForPath:(NSURL *)url {
    NSString *pathExtension = [url pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)pathExtension, NULL);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    return mimeType ? mimeType : @"application/octet-stream";
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"File selection canceled"];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

@end
