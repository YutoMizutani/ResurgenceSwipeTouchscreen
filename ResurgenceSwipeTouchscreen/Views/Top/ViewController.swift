//
//  ViewController.swift
//
//  Created by Yuto Mizutani on 2016/12/05.
//  Copyright © 2016年 Yuto Mizutani. All rights reserved.
//

import Foundation
import SwiftyDropbox

let statusbarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
let screenWidth: CGFloat = UIScreen.main.bounds.size.width
let screenHeight: CGFloat = UIScreen.main.bounds.size.height

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        layoutRect()
    }

    private func layoutRect() {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"

        // DropboxLoginButton
        let size: CGFloat = 75
        let button = UIButton(frame: CGRect(x: screenWidth - size - 10, y: statusbarHeight + 10, width: size, height: size))
        button.setImage(UIImage(named: "02"), for: .normal)
        button.tag = 1
        button.addTarget(self, action: #selector(setTUITR), for: .touchUpInside)
        view.addSubview(button)
        let iview = UIImageView(frame: CGRect(x: screenWidth - size - 10 + 5, y: statusbarHeight + 10 + 5, width: size - 5 * 2, height: size - 5 * 2))
        iview.isUserInteractionEnabled = false
        iview.image = UIImage(named: "dropbox-ios")
        view.addSubview(iview)

        let labelTitle = UILabel(frame: CGRect(x: 0, y: screenHeight / 20, width: screenWidth, height: screenHeight / 10))
        labelTitle.text = "Swiping on touchscreen"
        labelTitle.textAlignment = NSTextAlignment.center
        labelTitle.font = UIFont.systemFont(ofSize: screenHeight / 10 / 3)
        view.addSubview(labelTitle)

        let button10 = UIButton(frame: CGRect(x: screenWidth / 2 / 2, y: screenHeight / 20 * 5, width: screenWidth / 2, height: screenHeight / 20))
        button10.setTitle("Start Program", for: .normal)
        button10.setTitleColor(UIColor.blue, for: .normal)
        button10.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2 / 2)
        button10.titleLabel?.textAlignment = NSTextAlignment.center
        button10.tag = 10
        button10.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        button10.layer.borderWidth = 1
        button10.layer.borderColor = UIColor.lightGray.cgColor
        button10.layer.cornerRadius = 8
        view.addSubview(button10)

        let button13 = UIButton(frame: CGRect(x: screenWidth / 2 / 2, y: screenHeight / 20 * (5 + 6), width: screenWidth / 2, height: screenHeight / 20))
        button13.setTitle("Edit instructions", for: .normal)
        button13.setTitleColor(UIColor.blue, for: .normal)
        button13.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2 / 2)
        button13.titleLabel?.textAlignment = NSTextAlignment.center
        button13.tag = 13
        button13.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        button13.layer.borderWidth = 1
        button13.layer.borderColor = UIColor.lightGray.cgColor
        button13.layer.cornerRadius = 8
        view.addSubview(button13)

        let button14 = UIButton(frame: CGRect(x: screenWidth / 2 / 2, y: screenHeight / 20 * (5 + 8), width: screenWidth / 2, height: screenHeight / 20))
        button14.setTitle("Upload to Dropbox", for: .normal)
        button14.setTitleColor(UIColor.blue, for: .normal)
        button14.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2 / 2)
        button14.titleLabel?.textAlignment = NSTextAlignment.center
        button14.tag = 14
        button14.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        button14.layer.borderWidth = 1
        button14.layer.borderColor = UIColor.lightGray.cgColor
        button14.layer.cornerRadius = 8
        view.addSubview(button14)

        let button16 = UIButton(frame: CGRect(x: screenWidth / 2 / 2, y: screenHeight / 20 * (5 + 12), width: screenWidth / 2, height: screenHeight / 20))
        button16.setTitle("Legal", for: .normal)
        button16.setTitleColor(UIColor.darkGray, for: .normal)
        button16.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2 / 2)
        button16.titleLabel?.textAlignment = NSTextAlignment.center
        button16.tag = 16
        button16.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        button16.layer.borderWidth = 1
        button16.layer.borderColor = UIColor.lightGray.cgColor
        button16.layer.cornerRadius = 8
        view.addSubview(button16)
    }

    @IBAction private func setTUITR(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: self,
                                                          openURL: { (url: URL) -> Void in
                                                              UIApplication.shared.openURL(url)
                                                          })
        default:
            break
        }
    }

    @IBAction private func setTUI(_ sender: UIButton) {
        switch sender.tag {
        case 10:
            let viewController = UINavigationController(rootViewController: MenuViewController())
            viewController.title = "Experiment"
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            present(viewController, animated: true, completion: nil)
        case 13:
            let viewController = SetInstructions()
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            present(viewController, animated: true, completion: nil)
        case 14:
            let viewController = UploaderView()
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            present(viewController, animated: true, completion: nil)
        case 16:
            let viewController = LegalViewController()
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            present(viewController, animated: true, completion: nil)
        default:
            break
        }
    }
}
