//
//  BallStoreDataX.swift
//
//  Created by Yuto Mizutani on 2017/01/20.
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

import Foundation
import SwiftyDropbox

var someConditionIsSatisfied = false

class BallStoreDataX {
    func timeWrite() -> String {
        var timeData: String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        timeData = "StartTime: " + dateFormatter.string(from: StoreData.startDate!) + "\n"
        timeData += "EndTime: " + dateFormatter.string(from: StoreData.endDate!) + "\n"
        return timeData
    }

    func subjectsWrite(subjectName: String, sessionNumStr: String) -> String {
        return "Participant's Name: \(subjectName)\nSessionNum: \(sessionNumStr)\n"
    }

    // PARAMETERS
    func parametersWrite(storedParameter: StoredParameterable) -> String {
        var parameterData: String = "PARAMETERS\n"
        parameterData += "ExperimentType: " + "3D Ball swipe" + "\n"
        parameterData += "MaxSessionTime: \(storedParameter.sessionTimeMin)-min\n"
        parameterData += "UseRotation: \(storedParameter.isUseSensor ? "True" : "False")\n"
        parameterData += "UseDemo: \(storedParameter.isDemo ? "True" : "False")\n"

        let phases = storedParameter.phases
        for i in 0 ..< phases.count {
            parameterData += "[Phase\(i + 1)]\n"
            parameterData += "Schedule: \(phases[i].schedule == .EXT ? "\(phases[i].schedule)" : "\(phases[i].schedule) \(phases[i].schedParameter)")\n"
            parameterData += "Angle range (+/-): \(phases[i].toleranceAngle)\n"
            parameterData += "EndType: \(phases[i].endType == .Time ? "\(phases[i].endType) \(phases[i].endParameter)-min" : "\(phases[i].endType) \(phases[i].endParameter)")\n"
        }

        return parameterData
    }

    // DEPENDENT VARIABLES
    func dependentWrite(storedValue: StoredValuable) -> String {
        var dependentData: String = "DEPENDENT VARIABLES\n"
        dependentData += "[Total]\n"
        dependentData += "TargetResp: " + BallStoreData.targetResp.description + "\n"
        dependentData += "ControlResp: " + BallStoreData.controlResp.description + "\n"
        dependentData += "UnregisteredResp: " + BallStoreData.shortResp.description + "\n"
        /* dependentData += "wrongTouchPositionResp: " + BallStoreData.wrongPositionResp.description + "\n" */
        dependentData += "DoubleTap:" + BallStoreData.doubleTapAlertNum.description + "\n"
        dependentData += "Reinforcers: " + BallStoreData.reinforcer.description + "\n"
        dependentData += "SessionTime: " + StoreData.sessionTime.description + "\n"
        dependentData += "RealTime: " + StoreData.realTime.description + "\n"

        let phases = storedValue.phases
        for i in 0 ..< phases.count {
            dependentData += "[Phase\(i + 1)]\n"
            dependentData += "TargetResp: \(phases[i].targetResp)\n"
            dependentData += "ControlResp: \(phases[i].controlResp)\n"
            dependentData += "UnregisteredResp: \(phases[i].unregisterdResp)\n"
            dependentData += "DoubleTap: \(phases[i].doubleTapResp)\n"
            dependentData += "Reinforcers: \(phases[i].reinforcers)\n"
            dependentData += "TargetAngle: \(phases[i].targetAngle == 1000 ? "none" : "\(phases[i].targetAngle)")\n"
        }

        return dependentData
    }

    // EVENTS
    static var nextPhaseID: String = "07"
    func eventsWrite() -> String {
        var eventsData: String = "EVENTS\n"
        eventsData += BallStoreData.targetRespID + " = Target response\n"
        eventsData += BallStoreData.controlRespID + " = Control response\n"
        eventsData += BallStoreData.shortRespID + " = Unregistered response (SwipeLength < CriterionLength)\n"
        eventsData += BallStoreData.doubleTapID + " = Double tap\n"
        eventsData += BallStoreData.reinforcerOnID + " = Reinforcement onset (Star presented)\n"
        eventsData += BallStoreData.reinforcerOffID + " = Reinforcement offset (Star touched)\n"
        eventsData += BallStoreDataX.nextPhaseID + " = End/Next Phase\n"
        StoreData.endofsessionID = "99"
        eventsData += StoreData.endofsessionID + " = End of session\n"
        eventsData += BallStoreData.lengthID + " = Swipe length (marked when a finger is raised from the screen)\n"
        return eventsData
    }

    static var rawDataString: String = ""
    func endWrite(storedParameter: StoredParameterable, storedValue: StoredValuable) {
        BallStoreDataX.rawDataString = timeWrite() + "\n" + subjectsWrite(subjectName: storedParameter.subjectName, sessionNumStr: storedParameter.sessionNum.description) + "\n" + dependentWrite(storedValue: storedValue) + "\n" + parametersWrite(storedParameter: storedParameter) + "\n" + eventsWrite() + "\nList of events:\n" + StoreData.listData + StoreData.endofsessionID + ": \(StoreData.realTime)\n\nEND OF THE SESSION"
    }

    static func resetSwipeSessionData() {
        BallStoreData.ResetSessionData()
        BallStoreData.targetResp = 0
        BallStoreData.alternativeResp = 0
        BallStoreData.controlResp = 0
        BallStoreData.shortResp = 0
        BallStoreData.doubleTapAlertNum = 0
        BallStoreData.reinforcer = 0
        BallStoreData.swipeAngle = [Int](repeating: 0, count: 361)
    }

    static func textWriting(storedParameter: StoredParameterable) -> (isResult: Bool, fileName: String) { // ※上書きせず改行して追加
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/SwipeRawData"
        return BallStoreDataX.savingAtLocalFolder(storedParameter, path: documentsPath)
    }

    static func uploadErrorFilesSaving(storedParameter: StoredParameterable) -> (isResult: Bool, fileName: String) {
        let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/UploadErrorFiles"
        return BallStoreDataX.savingAtLocalFolder(storedParameter, path: libraryPath)
    }

    static func savingAtLocalFolder(_ storedParameter: StoredParameterable, path: String) -> (isResult: Bool, fileName: String) {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("couldn't create directory..")
        }

        let file = storedParameter.subjectName + "_" + storedParameter.sessionNum.description
        var rawFile = file + ".txt"
        var filePath = path + "/" + rawFile

        checkSameName: do {
            let manager = FileManager.default
            let list = try? manager.contentsOfDirectory(atPath: path)
            if list != nil {
                let lists = list!

                var i: Int = 0
                if !lists.isEmpty {
                    var x = 0
                    while true {
                        print("list: \(lists[x])")

                        // フォルダ内に同じファイル名があれば
                        if lists[x].range(of: rawFile) != nil {
                            print("フォルダ内に同じファイル名があった")
                            i += 1
                            rawFile = file + " (\(i))" + ".txt"
                            filePath = path + "/" + rawFile

                            x = 0
                        } else {
                            x += 1
                        }
                        print("現在：\(rawFile)")

                        // 最後のlistsに到達した場合
                        if x == lists.count {
                            // while loopを抜ける
                            break
                        }
                    }
                }
            }
        }

        do {
            try BallStoreDataX.rawDataString.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8) // Bool引数はfalseで上書き
        } catch {
            print("couldn't save file..")
            return (isResult: false, fileName: "")
        }
        return (isResult: true, fileName: rawFile)
    }

    static func textUploadDropbox(_ viewController: UIViewController, storedParameter: StoredParameterable) {
        func textUploadToDropbox(_ text: String, folderName: String, fileName: String, viewController: UIViewController) throws {
            let fileData = text.data(using: String.Encoding.utf8, allowLossyConversion: true)!
            if let dropBoxClient = client {
                let request = dropBoxClient.files.upload(path: "/" + folderName + "/" + fileName + ".txt", mode: Files.WriteMode.add, autorename: true, clientModified: nil, mute: true, input: fileData)
                    .response { response, error in
                        if response?.pathDisplay != nil {
                            callbackUploadDropbox(text, fileName: response!.pathDisplay!, response: response, viewController: viewController)
                        } else {
                            var errorText: String = ""
                            ErrorTextSearch: do {
                                if error != nil {
                                    print(error!.description)
                                    enum chrStateType {
                                        case begin, pickingText, end
                                    }
                                    var chrState: chrStateType = chrStateType.begin
                                    chrFindLoop: for chr in error!.description {
                                        switch chrState {
                                        case .begin:
                                            if chr == "\"" {
                                                chrState = .pickingText
                                            }
                                        case .pickingText:
                                            if chr == "\"" {
                                                chrState = .end
                                            } else {
                                                errorText += chr.description
                                            }
                                        case .end:
                                            break chrFindLoop
                                        }
                                        print("text: \(errorText), current:\(chr)")
                                    }
                                }
                            }
                            callbackUploadDropbox(text, fileName: folderName + "/" + fileName + ".txt", response: response, errorText: errorText, viewController: viewController)
                        }
                    }
                    .progress { progressData in
                        print("progressData: " + progressData.description)
                    }
            } else { throw DropboxUploadResultType.clientNilError }
        }
        func callbackUploadDropbox(_ text: String, fileName: String, response: (Files.FileMetadata)?, errorText: String? = nil, viewController: UIViewController) {
            if let response = response {
                print("response: " + response.description)
                popWaitingAlert(title: "Success: Upload to Dropbox", message: "fileName: \(fileName)")

                ResultViewController.didUpload = true
            } else if let errorText = errorText {
                print("couldn't upload file...")
                print("error: " + errorText)
                popWaitingAlert(title: "Failure: Upload to Dropbox", message: errorText)
            }
        }
        func popWaitingAlert(title: String = "", message: String = "", ActionTitle: String = "Done") {
            func getTopMostViewController() -> UIViewController? {
                // http://swift-salaryman.com/topmost.php
                var tc: UIViewController?
                DispatchQueue.main.async {
                    tc = UIApplication.shared.keyWindow?.rootViewController
                }
                if tc == nil {
                    return tc
                }
                while (tc!.presentedViewController) != nil {
                    if tc != nil, tc!.presentedViewController != nil {
                        tc = tc!.presentedViewController
                    } else {
                        return nil
                    }
                }
                return tc
            }
            DispatchQueue.global().async {
                while getTopMostViewController() is UIAlertController {}
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: ActionTitle, style: .default) { (_: UIAlertAction!) -> Void in
                    })
                    viewController.present(alert, animated: true, completion: nil)
                }
            }
        }

        if client != nil {
            do {
                try textUploadToDropbox(BallStoreDataX.rawDataString, folderName: storedParameter.subjectName, fileName: storedParameter.subjectName + "_" + storedParameter.sessionNum.description, viewController: viewController)
            } catch {
                print("error drop")
            }
        } else {
            print("client nil error")
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: viewController,
                                                          openURL: { (url: URL) -> Void in
                                                              UIApplication.shared.openURL(url)
                                                          })
        }
    }

    static func textReading() -> String {
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/SwipeRawData"
        let file = "/" + StoreData.subjectName + "_" + StoreData.sessionNum.description + ".txt"
        let filePath = documentsPath + file

        let fileURL = URL(fileURLWithPath: filePath)
        var text = ""
        do {
            try text = String(contentsOf: fileURL, encoding: String.Encoding.utf8)
        } catch {
            print("couldn't load file..")
        }
        return text
    }
}
