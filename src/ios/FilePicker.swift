import Foundation
import MobileCoreServices
import UIKit

@objc(FilePicker)
class FilePicker: CDVPlugin {
    
    @objc(selectFiles:)
    func selectFiles(command: CDVInvokedUrlCommand) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeItem)], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        self.viewController.present(documentPicker, animated: true, completion: nil)
    }
}

extension FilePicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var fileMetadata: [[String: Any]] = []

        for url in urls {
            let metadata: [String: Any] = [
                "filename": url.lastPathComponent,
                "filemime": url.mimeType(),
                "filepath": url.path
            ]
            fileMetadata.append(metadata)
        }

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: fileMetadata)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "User cancelled file selection")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
}

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension as NSString
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)?.takeRetainedValue() else { return "application/octet-stream" }
        guard let mimeType = UTTypeGetPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() else { return "application/octet-stream" }
        return mimeType as String
    }
}
