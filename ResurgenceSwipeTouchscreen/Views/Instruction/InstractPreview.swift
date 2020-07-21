//
//  Instract_Preview.swift
//
//  Created by Yuto Mizutani on 2017/04/20.
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

import Foundation
import UIKit

class InstructPreview: InstructParent {
    override func viewDidLoad() {
        super.viewDidLoad()
        previewlayout()
        parentValue()
    }

    func previewlayout() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenHeight, height: screenHeight))
        label.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        label.text = "Preview"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: screenHeight / 2 / 2)
        label.textColor = UIColor(white: 0.0, alpha: 0.1)
        view.addSubview(label)
        label.transform = CGAffineTransform.identity
        label.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(315) / 180))
    }

    func parentValue() {
        DispatchQueue.main.async {
            self.textv.text = SetInstructions.instStr
            let str: String = SetInstructions.instFontName
            let size: CGFloat = CGFloat(SetInstructions.instFontSize)
            if str == "System Font" {
                self.textv.font = UIFont.systemFont(ofSize: size)
            } else {
                self.textv.font = UIFont(name: str, size: size)
            }
            self.textv.textColor = SetInstructions.InstFontColor
        }
    }

    override func backButtonTUI() {
        super.backButtonTUI()
        dismiss(animated: true, completion: nil)
    }

    override func startButtonTUI() {
        super.startButtonTUI()
        dismiss(animated: true, completion: nil)
    }
}
