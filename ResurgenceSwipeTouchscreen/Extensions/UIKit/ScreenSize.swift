//
//  ScreenSize.swift
//
//  Created by YutoMizutani on 2017/06/23.
//  Copyright © 2017 Yuto Mizutani. All rights reserved.
//

import UIKit

extension UIView {
    var size: CGSize {
        return bounds.size
    }

    var width: CGFloat {
        return size.width
    }

    var height: CGFloat {
        return size.height
    }

    var long: CGFloat {
        return max(size.width, size.height)
    }

    var short: CGFloat {
        return min(size.width, size.height)
    }

    var isPortrait: Bool {
        return height >= width
    }

    var safeArea: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        } else {
            return .zero
        }
    }

    struct statusBar {
        private static let frame = UIApplication.shared.statusBarFrame

        static var width: CGFloat {
            return frame.width
        }

        static var height: CGFloat {
            return frame.height
        }
    }
}
