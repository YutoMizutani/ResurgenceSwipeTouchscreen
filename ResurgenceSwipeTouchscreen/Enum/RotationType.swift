//
//  RotationType.swift
//  SwipeProgram
//
//  Created by Yuto Mizutani on 2018/12/24.
//  Copyright © 2018 Yuto Mizutani. All rights reserved.
//

import Foundation

enum RotationType {
    case angle(Int)
    case horizontal
}

extension RotationType {
    static func create(_ angle: Int?) -> RotationType {
        return angle == nil ? .horizontal : .angle(angle!)
    }

    var description: String {
        switch self {
        case let .angle(v):
            return "\(v)"
        case .horizontal:
            return "Horizontal"
        }
    }
}
