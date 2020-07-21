//
//  EnumXVII.swift
//
//  Created by Yuto Mizutani on 2020/07/21.
//  Copyright © 2020 Yuto Mizutani. All rights reserved.
//

import Foundation

enum AngleDeterminationRealmType: String, CaseIterable {
    case straight = "+180 degrees"
    case least = "The least"
    case mix = "+180 degrees is the least, or another random"
    case random = "Random"

    static func getType(_ str: String) -> AngleDeterminationRealmType? {
        for type in AngleDeterminationRealmType.allCases {
            if type.rawValue == str {
                return type
            }
        }
        return nil
    }
}

enum ScheduleRealmType: String, CaseIterable {
    case FR
    case EXT
}

enum TargetAngleRealmType: String, CaseIterable {
    case alternativeResponse = "Alternative response"
    case angle = "Angle"
}

enum EndRealmType: String, CaseIterable {
    case Swipe
    case SR
    case Time
}
