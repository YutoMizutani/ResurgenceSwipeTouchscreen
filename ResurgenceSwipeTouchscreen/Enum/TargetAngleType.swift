//
//  TargetAngleType.swift
//  SwipeProgram
//
//  Created by Yuto Mizutani on 2018/12/08.
//  Copyright © 2018 Yuto Mizutani. All rights reserved.
//

import Foundation

enum TargetAngleType {
    case firstResponse, angle
}

extension TargetAngleType {
    var description: String {
        switch self {
        case .firstResponse:
            return "First response"
        case .angle:
            return "Angle"
        }
    }
}
