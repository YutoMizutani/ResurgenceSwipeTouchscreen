//
//  StoredParameter.swift
//
//  Created by YutoMizutani on 2017/07/26.
//  Copyright © 2017 Yuto Mizutani. All rights reserved.
//

import Foundation

protocol StoredParameterable {
    var subjectName: String { get }
    var sessionNum: Int { get }
    var password: String { get }
    var sessionTimeMin: Int { get }
    var angleAlgorithm: AngleAlgorithmType { get }
    var isUseSensor: Bool { get }
    var isDemo: Bool { get }
    var phases: [PhaseParameter] { get }
    func addPhase(schedule: ScheduleType, schedParameter: Int, userAngle: Int?, toleranceAngle: Int, endType: EndType, endParameter: Int)
    func getCurrentPhases(_ phaseNum: Int) -> PhaseParameter
    func printParameter()
}

class StoredEmptyParameter: StoredParameterable {
    let subjectName: String = ""
    let sessionNum: Int = 0
    let password: String = ""
    let sessionTimeMin: Int = 0
    let angleAlgorithm: AngleAlgorithmType = .plus180
    var isUseSensor: Bool = true
    let isDemo: Bool = true
    let phases: [PhaseParameter] = []
    func addPhase(schedule: ScheduleType, schedParameter: Int, userAngle: Int? = nil, toleranceAngle: Int, endType: EndType, endParameter: Int) {}
    func getCurrentPhases(_ phaseNum: Int) -> PhaseParameter { return PhaseParameter(schedule: .EXT, schedParameter: 0, userAngle: nil, toleranceAngle: 0, endType: .SR, endParameter: 0) }
    func printParameter() {}
}

class StoredParameterXIII: StoredParameterable {
    let subjectName: String
    let sessionNum: Int
    let password: String
    let sessionTimeMin: Int
    let angleAlgorithm: AngleAlgorithmType
    let isUseSensor: Bool
    let isDemo: Bool

    init(subjectName: String, sessionNum: Int, password: String, sessionTimeMin: Int, angleAlgorithm: AngleAlgorithmType, isUseSensor: Bool = true, isDemo: Bool) {
        self.subjectName = subjectName
        self.sessionNum = sessionNum
        self.password = password
        self.sessionTimeMin = sessionTimeMin
        self.angleAlgorithm = angleAlgorithm
        self.isUseSensor = isUseSensor
        self.isDemo = isDemo
    }

    private(set) var phases: [PhaseParameter] = []

    func addPhase(schedule: ScheduleType, schedParameter: Int, userAngle: Int? = nil, toleranceAngle: Int, endType: EndType, endParameter: Int) {
        phases.append(PhaseParameter(schedule: schedule, schedParameter: schedParameter, userAngle: userAngle, toleranceAngle: toleranceAngle, endType: endType, endParameter: endParameter))
    }

    func getCurrentPhases(_ phaseNum: Int) -> PhaseParameter {
        return phases[phaseNum - 1]
    }

    func printParameter() {
        print("subjectName: \(subjectName)")
        print("sessionNum: \(sessionNum)")
        print("password: \(password)")
        print("sessionTimeMin: \(sessionTimeMin)")
        print("\(angleAlgorithm)")
        print("isDemo: \(isDemo)")
        print("phases: \(phases)")
    }
}

enum ScheduleType {
    case EXT, FR
    static func getType(_ index: Int) -> ScheduleType {
        switch index {
        case 0:
            return .EXT
        case 1:
            fallthrough
        default:
            return .FR
        }
    }
}

enum EndType {
    case Swipe, SR, Time
    static func getType(_ index: Int) -> EndType {
        switch index {
        case 0:
            return .Swipe
        case 1:
            return .SR
        case 2:
            fallthrough
        default:
            return .Time
        }
    }
}

enum AngleAlgorithmType {
    case plus180, plus180andLeast, least, angle, theLeast180OrAnotherRandom, random, plus180XVI, theLeastXVI
    static func getType(_ index: Int) -> AngleAlgorithmType {
        switch index {
        case 0:
            return .plus180
        case 1:
            return .plus180andLeast
        case 2:
            return .least
        case 3:
            return .angle
        case 4:
            return .theLeast180OrAnotherRandom
        case 5:
            return .random
        case 6:
            return .plus180XVI
        case 7:
            return .theLeastXVI
        default:
            return .random
        }
    }
}

class PhaseParameter {
    var schedule: ScheduleType
    var schedParameter: Int
    var userAngle: Int?
    var toleranceAngle: Int
    var endType: EndType
    var endParameter: Int

    init(schedule: ScheduleType, schedParameter: Int, userAngle: Int?, toleranceAngle: Int, endType: EndType, endParameter: Int) {
        self.schedule = schedule
        self.schedParameter = schedParameter
        self.userAngle = userAngle
        self.toleranceAngle = toleranceAngle
        self.endType = endType
        self.endParameter = endParameter
    }
}
