//
//  ResultModek.swift
//
//  Created by YutoMizutani on 2017/06/25.
//  Copyright © 2017 Yuto Mizutani. All rights reserved.
//

import Foundation
import UIKit

protocol ResultModel {
    func checkDropBoxLoggingState() -> Bool
    func logIntoDropbox(_ controller: UIViewController)
    func textLocalSave(_ text: String, folderType: OCAFolderType, folderName: String, fileName: String) throws
    func textUploadToDropbox(_ text: String, folderName: String, fileName: String, viewController: UIViewController?) throws
}

protocol CallbackUploadDropboxModel {
    func callback(_ dropboxUploadResultType: DropboxUploadResultType)
}

class ResultModelImpl: ResultModel, CallbackUploadDropboxModel {
    var fileSaveModel: FileSaveModelImpl
    var fileUploadDropboxModel: FileUploadDropboxModelImpl

    init() {
        self.fileSaveModel = FileSaveModelImpl()
        self.fileUploadDropboxModel = FileUploadDropboxModelImpl(fileSaveModel)
    }

    func inject() {
        fileUploadDropboxModel.inject(self)
    }

    func checkDropBoxLoggingState() -> Bool {
        return fileUploadDropboxModel.checkLoggingStateDropbox()
    }

    func logIntoDropbox(_ controller: UIViewController) {
        fileUploadDropboxModel.LogIntoDropbox(controller)
    }

    func textLocalSave(_ text: String, folderType: OCAFolderType, folderName: String, fileName: String) throws {
        try fileSaveModel.textLocalSave(text, folderType: folderType, folderName: folderName, fileName: fileName)
    }

    func textUploadToDropbox(_ text: String, folderName: String, fileName: String, viewController: UIViewController?) throws {
        try fileUploadDropboxModel.textUploadToDropbox(text, folderName: folderName, fileName: fileName, viewController: viewController)
    }

    func callback(_ dropboxUploadResultType: DropboxUploadResultType) {
        var massage: String = ""
        switch dropboxUploadResultType {
        case .success:
            massage = "Success to upload"
        case .clientNilError, .noWorkingError, .unknownError:
            massage = "failed to upload (" + dropboxUploadResultType.localizedDescription + "!)"
        case let .uploadError(_, value):
            massage = "failed to upload (" + dropboxUploadResultType.localizedDescription + ")\n" + "and local Saving: " + (value != nil ? "failed" : "success")
        }
    }
}
