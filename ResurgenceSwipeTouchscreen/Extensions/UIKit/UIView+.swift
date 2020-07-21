//
//  UIView+.swift
//
//  Created by Yuto Mizutani on 2018/12/22.
//  Copyright © 2018 Yuto Mizutani. All rights reserved.
//

import UIKit

extension UIView {
    func addSubview(_ views: UIView?...) {
        views.filter { $0 != nil }.map { $0! }.forEach { addSubview($0) }
    }
}
