//
//  CriterionType.swift
//  SwipeProgram
//
//  Created by Yuto Mizutani on 2018/12/08.
//  Copyright © 2018 Yuto Mizutani. All rights reserved.
//

import Foundation

enum CriterionType {
    case swipe, reinforcement, minutes
}

extension CriterionType {
    var description: String {
        switch self {
        case .swipe:
            return "Swipe"
        case .reinforcement:
            return "SR"
        case .minutes:
            return "Time"
        }
    }
}
