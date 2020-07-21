//
//  BallStoreData.swift
//
//  Created by Yuto Mizutani on 2017/04/10.
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

import Foundation
import SwiftyDropbox

class BallStoreData: StoreData {
    static var swipeAngle: [Int] = [] // [Int](repeating:0, count:361) //0-360

    // PARAMETERS
    static var angleMin: Int = 0
    static var angleMax: Int = 45
    static var angleMin_2: Int = 0
    static var angleMax_2: Int = 45
    static var value: Int = 3

    static var dropboxState: Bool = false

    override func parametersWrite() -> String {
        var parameterData: String = "PARAMETERS\n"
        parameterData += "ExperimentType: " + "BallSwipe" + "\n"
        parameterData += "Schedule: " + StoreData.scheduleStr + "\n"
        parameterData += "Value: " + BallStoreData.value.description + "\n"
        parameterData += "MinAngle: " + BallStoreData.angleMin.description + "\n"
        parameterData += "MaxAngle: " + BallStoreData.angleMax.description + "\n"
        /* parameterData += "MaxReinforcers: " + StoreData.maxReinforcers.description + "\n" */
        parameterData += "MaxSessionTime: " + StoreData.maxSessionTime.description + "\n"
        /* parameterData += "ReinforcementDuration: " + StoreData.rftDuration.description + "\n" */
        return parameterData
    }

    func parametersWrite_2() -> String {
        var parameterData: String = "PARAMETERS\n"
        parameterData += "ExperimentType: " + StoreData.experimentType + "\n"
        parameterData += "Schedule: " + StoreData.scheduleStr + "\n"
        parameterData += "SchedulePara: " + BallStoreData.value.description + "\n"
        parameterData += "MinAngle_1: " + BallStoreData.angleMin.description + "\n"
        parameterData += "MaxAngle_1: " + BallStoreData.angleMax.description + "\n"
        parameterData += "MinAngle_2: " + BallStoreData.angleMin_2.description + "\n"
        parameterData += "MaxAngle_2: " + BallStoreData.angleMax_2.description + "\n"
        parameterData += "MaxReinforcers: " + StoreData.maxReinforcers.description + "\n"
        parameterData += "MaxSessionTime: " + StoreData.maxSessionTime.description + "\n"
        parameterData += "ReinforcementDuration: " + StoreData.rftDuration.description + "\n"
        return parameterData
    }

    // DEPENDENT VARIABLES
    static var targetResp: Int = 0
    static var alternativeResp: Int = 0
    static var controlResp: Int = 0
    static var shortResp: Int = 0
    static var wrongPositionResp: Int = 0
    static var doubleTapAlertNum: Int = 0
    static var reinforcer: Int = 0
    override func dependentWrite() -> String {
        var dependentData: String = "DEPENDENT VARIABLES\n"
        dependentData += "TargetResp: " + BallStoreData.targetResp.description + "\n"
        dependentData += "ControlResp: " + BallStoreData.controlResp.description + "\n"
        dependentData += "UnregisteredResp: " + BallStoreData.shortResp.description + "\n"
        /* dependentData += "wrongTouchPositionResp: " + BallStoreData.wrongPositionResp.description + "\n" */
        dependentData += "DoubleTap:" + BallStoreData.doubleTapAlertNum.description + "\n"
        dependentData += "Reinforcers: " + BallStoreData.reinforcer.description + "\n"
        /* dependentData += "SessionTime: " + StoreData.sessionTime.description + "\n" */
        dependentData += "RealTime: " + StoreData.realTime.description + "\n"
        return dependentData
    }

    // EVENTS
    static var targetRespID: String = "01"
    static var controlRespID: String = "02"
    static var shortRespID: String = "03"
    static var doubleTapID: String = "04"
    static var reinforcerOnID: String = "05"
    static var reinforcerOffID: String = "06"
    static var lengthID: String = "LEN"
    override func eventsWrite() -> String {
        var eventsData: String = "EVENTS\n"
        eventsData += BallStoreData.targetRespID + " = Target response\n"
        eventsData += BallStoreData.controlRespID + " = Control response\n"
        eventsData += BallStoreData.shortRespID + " = Unregistered response (SwipeLength < CriterionLength)\n"
        eventsData += BallStoreData.doubleTapID + " = Double tap\n"
        eventsData += BallStoreData.reinforcerOnID + " = Reinforcement onset (Star presented)\n"
        eventsData += BallStoreData.reinforcerOffID + " = Reinforcement offset (Star touched)\n"
        StoreData.endofsessionID = "99"
        eventsData += StoreData.endofsessionID + " = End of session\n"
        eventsData += BallStoreData.lengthID + " = Swipe length (marked when a finger is raised from the screen)\n"
        return eventsData
    }

    override func endWrite() {
        StoreData.rawDataString = timeWrite() + "\n" + subjectsWrite() + "\n" + dependentWrite() + "\n" + parametersWrite() + "\n" + eventsWrite() + "\nList of events:\n" + StoreData.listData + StoreData.endofsessionID + ": " + Int(StoreData.endDate!.timeIntervalSince(StoreData.startDate!) * 1000).description + "\n\nEND OF THE SESSION"
    }

    func endWrite_2() {
        StoreData.rawDataString = timeWrite() + "\n" + subjectsWrite() + "\n" + dependentWrite() + "\n" + parametersWrite_2() + "\n" + eventsWrite() + "\nList of events:\n" + StoreData.listData + StoreData.endofsessionID + ": " + Int(StoreData.endDate!.timeIntervalSince(StoreData.startDate!) * 1000).description + "\n\nEND OF THE SESSION"
    }

    static func resetSwipeSessionData() {
        ResetSessionData()
        targetResp = 0
        alternativeResp = 0
        controlResp = 0
        shortResp = 0
        doubleTapAlertNum = 0
        reinforcer = 0
        swipeAngle = [Int](repeating: 0, count: 361)
    }

    static func textWriting() -> Bool {
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/SwipeRawData"
        let file = "/" + StoreData.subjectName + "_" + StoreData.sessionNum.description + ".txt"
        let filePath = documentsPath + file
        do {
            try FileManager.default.createDirectory(atPath: documentsPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("couldn't create directory..")
        }
        do {
            try StoreData.rawDataString.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print("couldn't save file..")
            return false
        }
        return true
    }

    static func textUploadDropbox() {
        let fileData = StoreData.rawDataString.data(using: String.Encoding.utf8, allowLossyConversion: false)!

        if client != nil {
            let request = client?.files.upload(path: "/" + StoreData.subjectName + "/" + StoreData.subjectName + "_" + StoreData.sessionNum.description + ".txt", input: fileData)
                .response { response, error in
                    if let response = response {
                        print("response: " + response.description)
                    } else if let error = error {
                        print("couldn't upload file..")
                        print("error: " + error.description)
                        uploadErrorFilesSaving()
                    }
                }
                .progress { progressData in
                    print("progressData: " + progressData.description)
                }
        } else {
            print("client nil error")
            print("couldn't upload file...")
            uploadErrorFilesSaving()
        }
    }

    static func uploadErrorFilesSaving() {
        let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/UploadErrorFiles"
        let file = "/" + StoreData.subjectName + "_" + StoreData.sessionNum.description + ".txt"
        let filePath = libraryPath + file
        do {
            try FileManager.default.createDirectory(atPath: libraryPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("couldn't create directory..")
        }
        do {
            // Bool引数はfalseで上書き
            try StoreData.rawDataString.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print("couldn't save file..")
        }
    }

    static func textReading() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/SwipeRawData"
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
