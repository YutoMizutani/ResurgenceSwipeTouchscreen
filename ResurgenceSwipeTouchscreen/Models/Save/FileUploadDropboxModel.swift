//
//  FileSaving.swift
//
//  Created by Yuto Mizutani on 2017/04/12.
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

// Local SaveとDropbox Saveのfunction。

import Foundation
import SwiftyDropbox

enum DropboxUploadResultType: Error {
    case success, uploadError(error: String, localSaveError: Error?), clientNilError, noWorkingError, unknownError
}

protocol FileUploadDropboxModel {
    var fileSaveModel: FileSaveModel { get }
    var dropboxClient: DropboxClient? { get set }
    func checkLoggingStateDropbox() -> Bool
    func LogOutDropbox()
    func LogIntoDropbox(_ controller: UIViewController)
    func textUploadToDropbox(_ text: String, folderName: String, fileName: String, viewController: UIViewController?) throws
}

class FileUploadDropboxModelImpl: FileUploadDropboxModel {
    var fileSaveModel: FileSaveModel
    var callbackUploadDropboxModel: CallbackUploadDropboxModel?
    var dropboxClient: DropboxClient?

    init(_ fileSaveModel: FileSaveModel) {
        self.fileSaveModel = fileSaveModel
        self.dropboxClient = DropboxClientsManager.authorizedClient
    }

    func inject(_ callbackUploadDropboxModel: CallbackUploadDropboxModel) {
        self.callbackUploadDropboxModel = callbackUploadDropboxModel
    }

    func checkLoggingStateDropbox() -> Bool {
        return dropboxClient?.users != nil
    }

    func LogOutDropbox() {
        DropboxClientsManager.unlinkClients()
    }

    func LogIntoDropbox(_ controller: UIViewController) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: controller,
                                                      openURL: { (url: URL) -> Void in
                                                          UIApplication.shared.openURL(url)
                                                      })
    }

    func textUploadToDropbox(_ text: String, folderName: String, fileName: String, viewController: UIViewController?) throws {
        let fileData = text.data(using: String.Encoding.utf8, allowLossyConversion: true)!

        if dropboxClient == nil { throw DropboxUploadResultType.clientNilError }

        _ = dropboxClient?.files.upload(path: "/" + folderName + "/" + fileName + ".txt", mode: .add, autorename: true, clientModified: nil, mute: true, input: fileData)
            .response { response, error in
                self.callbackUploadDropbox(text, folderName: folderName, fileName: fileName, response: response, callError: error)
            }
            .progress { progressData in
                print("progressData: " + progressData.description)
            }
    }

    func callbackUploadDropbox(_ text: String, folderName: String, fileName: String, response: (Files.FileMetadata)?, callError: CallError<Files.UploadError>?) {
        if let response = response {
            print("response: " + response.description)
            callbackUploadDropboxModel?.callback(DropboxUploadResultType.success)
        } else if let callError = callError {
            print("couldn't upload file...")
            print("error: " + callError.description)
            do {
                try fileSaveModel.textLocalSave(text, folderType: OCAFolderType.uploadErrorFolder, folderName: folderName, fileName: fileName)
            } catch {
                callbackUploadDropboxModel?.callback(DropboxUploadResultType.uploadError(error: callError.description, localSaveError: error))
            }
            callbackUploadDropboxModel?.callback(DropboxUploadResultType.uploadError(error: callError.description, localSaveError: nil))
        }
    }
}
