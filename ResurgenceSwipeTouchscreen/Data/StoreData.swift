//
//  StoreData.swift
//
//  Created by Yuto Mizutani on 2016/12/06.
//  Copyright © 2016年 Yuto Mizutani. All rights reserved.
//

import Foundation

class StoreData {
    // TIME
    static var startDate: Date?
    static var endDate: Date?
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

    // SUBJECTS
    static var subjectName: String = "NoName"
    static var sessionNum: Int = 1
    static var phaseNum: Int = 0
    func subjectsWrite() -> String {
        return "Subject: " + StoreData.subjectName + "\nSessionNum: " + StoreData.sessionNum.description + "\nPhase: " + StoreData.phaseNum.description + "\n"
    }

    // PARAMETERS
    static var experimentType: String = ""
    static var scheduleStr: String = ""
    static var maxReinforcers: Int = 20
    static var maxSessionTime: Int = 0
    static var rftDuration: Double = 1.2
    func parametersWrite() -> String {
        var parameterData: String = "PARAMETERS\n"
        parameterData += "ExperimentType: " + StoreData.experimentType + "\n"
        parameterData += "Schedule: " + StoreData.scheduleStr + "\n"
        parameterData += "MaxReinforcers: " + StoreData.maxReinforcers.description + "\n"
        parameterData += "MaxSessionTime: " + StoreData.maxSessionTime.description + "\n"
        parameterData += "ReinforcementDuration: " + StoreData.rftDuration.description + "\n"
        return parameterData
    }

    // DEPENDENT VARIABLES
    static var responses: [Int] = []
    static var reinforcers: [Int] = []
    // ※static var components
    static var sessionTime: Int = 0
    static var realTime: Int = 0
    func dependentWrite() -> String {
        var dependentData: String = "DEPENDENT VARIABLES\n"
        if !StoreData.responses.isEmpty {
            for i in 0 ..< StoreData.responses.count {
                dependentData += "Responses(" + (i + 1).description + "): " + StoreData.responses[i].description + "\n"
            }
        }
        if !StoreData.reinforcers.isEmpty {
            for i in 0 ..< StoreData.reinforcers.count {
                dependentData += "Reinforcers(" + (i + 1).description + "): " + StoreData.reinforcers[i].description + "\n"
            }
        }
        // ※comp
        dependentData += "SessionTime: " + StoreData.sessionTime.description + "\n"
        dependentData += "RealTime: " + StoreData.realTime.description + "\n"
        return dependentData
    }

    func addRespSR(num: Int) {
        for _ in 0 ..< num {
            StoreData.responses.append(0)
            StoreData.reinforcers.append(0)
        }
    }

    // EVENTS
    static var endofsessionID = ""
    func eventsWrite() -> String {
        var eventsData: String = "EVENTS\n"
        var eventNum: Int = 1
        if !StoreData.responses.isEmpty {
            for i in 0 ..< StoreData.responses.count {
                // 逆算はresponses[i]-StrDigit(num:i+1)
                eventsData += StrDigit(num: eventNum) + " = " + "Response(" + (i + 1).description + ")\n"
                eventNum += 1
            }
        }
        if !StoreData.reinforcers.isEmpty {
            for i in 0 ..< StoreData.reinforcers.count {
                // 逆算はreinforcers[i]-StrDigit(num:responses.count+i*2)
                eventsData += StrDigit(num: eventNum) + " = " + "Reinforcement(" + (i * 2 + 1).description + ") onset\n"
                // 逆算はreinforcers[i]-StrDigit(num:responses.count+i*2+1)
                eventsData += StrDigit(num: eventNum + 1) + " = " + "Reinforcement(" + (i * 2 + 2).description + ") offset\n"
                eventNum += 2
            }
        }
        // ※components
        if eventNum <= 99 {
            StoreData.endofsessionID = "99"
        } else {
            StoreData.endofsessionID = "XX"
        }
        eventsData += StoreData.endofsessionID + " = End of session\n"
        return eventsData
    }

    func StrDigit(num: Int) -> String {
        if num < 10 {
            return "0" + num.description
        } else {
            return num.description
        }
    }

    // List of events
    static var listData: String = ""

    // end of the session
    static var rawDataString: String = ""
    func endWrite() {
        StoreData.rawDataString = timeWrite() + "\n" + subjectsWrite() + "\n" + dependentWrite() + "\n" + parametersWrite() + "\n" + eventsWrite() + "\nList of events:\n" + StoreData.listData + StoreData.endofsessionID + ": " + StoreData.endDate!.timeIntervalSince(StoreData.startDate!).description + "\n\nEND OF THE SESSION"
    }

    static func ResetSessionData() {
        responses = []
        reinforcers = []
        listData = ""
    }
}
