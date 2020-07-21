//
//  SwipeScheduleType.swift
//  SwipeProgram
//
//  Created by Yuto Mizutani on 2018/12/08.
//  Copyright © 2018 Yuto Mizutani. All rights reserved.
//

import Foundation

enum SwipeScheduleType {
    case fixedRatio, extinction
}

extension SwipeScheduleType {
    var shortName: String {
        switch self {
        case .fixedRatio:
            return "FR"
        case .extinction:
            return "EXT"
        }
    }
}
