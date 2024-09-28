import Foundation
import UIKit
import Cordova

@objc(FilePicker)
class FilePicker: CDVPlugin {
    
    @objc(selectFiles:)
    func selectFiles(command: CDVInvokedUrlCommand) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        
        self.viewController.present(documentPicker, animated: true, completion: nil)
    }
}

extension FilePicker: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var resultArray = [[String: Any]]()
        
        for url in urls {
            if let fileData = getFileMetadata(from: url) {
                resultArray.append(fileData)
            }
        }
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: resultArray)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "File selection cancelled")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    private func getFileMetadata(from url: URL) -> [String: Any]? {
        var fileData: [String: Any] = [:]
        
        do {
            let resourceValues = try url.resourceValues(forKeys: [.nameKey, .typeIdentifierKey])
            fileData["filename"] = resourceValues.name
            fileData["filemime"] = resourceValues.typeIdentifier
            fileData["filepath"] = url.absoluteString
        } catch {
            print("Error fetching file metadata: \(error)")
            return nil
        }
        
        return fileData
    }
}
