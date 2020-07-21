//
//  SessionEventType.swift
//  SwipeProgram
//
//  Created by Yuto Mizutani on 2018/12/24.
//  Copyright © 2018 Yuto Mizutani. All rights reserved.
//

import Foundation

enum SessionEventType {
    case targetResponse
    case controlResponse
    case unregisteredResponse
    case doubleTap
    case reinforcementOnSet
    case reinforcementOffSet
    case nextOrEndPhase
    case endOfSession
    case swipeLength
}

extension SessionEventType {
    var description: String {
        switch self {
        case .targetResponse:
            return "Target response"
        case .controlResponse:
            return "Control response"
        case .unregisteredResponse:
            return "Unregistered response (Swipe length < Criterion length)"
        case .doubleTap:
            return "Double tap"
        case .reinforcementOnSet:
            return "Reinforcement onset (Star presented)"
        case .reinforcementOffSet:
            return "Reinforcement offset (Star touched)"
        case .nextOrEndPhase:
            return "Next/End phase"
        case .endOfSession:
            return "End of session"
        case .swipeLength:
            return "Swipe length (marked when a finger is raised from the screen)"
        }
    }

    var mark: String {
        switch self {
        case .targetResponse:
            return "01"
        case .controlResponse:
            return "02"
        case .unregisteredResponse:
            return "03"
        case .doubleTap:
            return "04"
        case .reinforcementOnSet:
            return "05"
        case .reinforcementOffSet:
            return "06"
        case .nextOrEndPhase:
            return "07"
        case .endOfSession:
            return "99"
        case .swipeLength:
            return "LEN"
        }
    }
}
