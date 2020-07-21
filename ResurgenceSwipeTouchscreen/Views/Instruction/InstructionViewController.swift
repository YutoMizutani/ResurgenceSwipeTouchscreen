//
//  InstructionViewController.swift
//
//  Created by YutoMizutani on 2017/07/21.
//  Copyright © 2017 Yuto Mizutani. All rights reserved.
//

import Foundation
import UIKit

class InstructionViewController: InstructParent {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.viewWithTag(2)!.isHidden = !ExperimentViewController.storedParameter.isDemo
    }

    override func backButtonTUI() {
        super.backButtonTUI()
        dismiss(animated: true, completion: nil)
    }

    override func startButtonTUI() {
        super.startButtonTUI()
        let viewController = ExperimentViewController()
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(viewController, animated: true, completion: nil)
    }
}

extension InstructionViewController {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("self.view.subviews.count: \(view.subviews.count)")
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        print("self.view.subviews.count: \(view.subviews.count)")
        view = nil
    }
}

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------- */
