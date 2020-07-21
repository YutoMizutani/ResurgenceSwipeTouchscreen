//
//  FileSaving.swift
//
//  Created by Yuto Mizutani on 2017/04/12.
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

// Local SaveとDropbox Saveのfunction。

import Foundation

enum OCAFolderType: String {
    case rawDataFolder = "OCARawData"
    case uploadErrorFolder = "OCAUploadErrorFiles"
}

enum SaveFileErrorType: Error {
    case createDirectoryError // = "Couldn't create directory..."
    case saveError // = "Couldn't save file..."
}

enum LoadFileErrorType: Error {
    case loadError // = "Couldn't load file..."
}

protocol FileSaveModel {
    func textLocalSave(_ text: String, folderType: OCAFolderType, folderName: String, fileName: String) throws
    func textLocalRead(folderType: OCAFolderType, folderName: String, fileName: String) throws -> String
}

struct FileSaveModelImpl: FileSaveModel {
    func textLocalSave(_ text: String, folderType: OCAFolderType, folderName: String, fileName: String) throws {
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/" + folderType.rawValue
        let file = "/" + folderName + "/" + fileName + ".txt"
        let filePath = documentsPath + file // "/SwiperawData/" + file
        do {
            try FileManager.default.createDirectory(atPath: documentsPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw SaveFileErrorType.createDirectoryError
        }
        do {
            try text.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8) // Bool引数はfalseで上書き
        } catch {
            throw SaveFileErrorType.saveError
        }
    }

    func textLocalRead(folderType: OCAFolderType, folderName: String, fileName: String) throws -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/" + folderType.rawValue
        let file = "/" + folderName + "/" + fileName + ".txt"
        let filePath = documentsPath + file // "/SwiperawData/" + file

        let fileURL = URL(fileURLWithPath: filePath)
        var result = ""
        do {
            try result = String(contentsOf: fileURL, encoding: String.Encoding.utf8)
        } catch {
            throw LoadFileErrorType.loadError
        }
        return result
    }
}
