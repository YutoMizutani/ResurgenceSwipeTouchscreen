//
//  AlertColorSlider.swift
//
//  Created by Yuto Mizutani on 2017/04/20.
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

import Foundation
import UIKit

class AlertColorSlider: UIViewController {
    var ColorRGB: [CGFloat] = [0, 0, 0]

    var blurRect: UIVisualEffectView = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var BlurButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var alertRect: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 320 / 5 * 3)) // CGRect(x:0, y:0, width:0, height:0))
    var subAlertTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertLabel1 = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertLabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertLabel3 = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertLabel4 = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertSlider1 = UISlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertSlider2 = UISlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertSlider3 = UISlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertSlider4 = UISlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertButton1 = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var subAlertButton2 = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "userColorR") != nil {
            ColorRGB[0] = CGFloat(userDefaults.float(forKey: "userColorR"))
            ColorRGB[1] = CGFloat(userDefaults.float(forKey: "userColorG"))
            ColorRGB[2] = CGFloat(userDefaults.float(forKey: "userColorB"))
        }

        layoutSubThreeA()
        positionSubThreeA()
    }

    func layoutSubThreeA() {
        blurRect.isUserInteractionEnabled = true
        blurRect.effect = UIBlurEffect(style: .dark) // UIVisualEffectView(effect:UIBlurEffect(style: .light))
        // ※Viewタッチ反応を検出しない→透明ボタンをViewに重ねる
        BlurButton.backgroundColor = UIColor.clear
        BlurButton.addTarget(self, action: #selector(blurTUI), for: .touchUpInside)
        blurRect.contentView.addSubview(BlurButton)
        view.addSubview(blurRect)

        alertRect.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        alertRect.layer.cornerRadius = alertRect.bounds.width / 4 / 3
        alertRect.clipsToBounds = true
        view.addSubview(alertRect)

        subAlertTitle.textAlignment = .center
        subAlertTitle.text = "Text color"
        subAlertTitle.textColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        subAlertTitle.layer.borderColor = UIColor.darkGray.cgColor
        subAlertTitle.layer.borderWidth = 0.3
        subAlertTitle.clipsToBounds = true
        alertRect.addSubview(subAlertTitle)

        subAlertLabel1.textAlignment = .right
        subAlertLabel2.textAlignment = .right
        subAlertLabel3.textAlignment = .right
        subAlertLabel4.textAlignment = .right
        subAlertLabel1.text = "R:"
        subAlertLabel2.text = "G:"
        subAlertLabel3.text = "B:"
        subAlertLabel4.text = "Alpha:"
        alertRect.addSubview(subAlertLabel1)
        alertRect.addSubview(subAlertLabel2)
        alertRect.addSubview(subAlertLabel3)
        // alertRect.addSubview(subAlertLabel4)

        subAlertSlider1.minimumTrackTintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        subAlertSlider2.minimumTrackTintColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        subAlertSlider3.minimumTrackTintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        subAlertSlider1.addTarget(self, action: #selector(alertSliderChanged), for: UIControl.Event.valueChanged)
        subAlertSlider2.addTarget(self, action: #selector(alertSliderChanged), for: UIControl.Event.valueChanged)
        subAlertSlider3.addTarget(self, action: #selector(alertSliderChanged), for: UIControl.Event.valueChanged)
        alertRect.addSubview(subAlertSlider1)
        alertRect.addSubview(subAlertSlider2)
        alertRect.addSubview(subAlertSlider3)
        // alertRect.addSubview(subAlertSlider4)

        subAlertButton1.titleLabel!.textAlignment = .center
        subAlertButton1.setTitle("Cancel", for: .normal)
        subAlertButton1.backgroundColor = UIColor.clear
        subAlertButton1.setTitleColor(UIColor(red: 0.0, green: 0.4, blue: 1.0, alpha: 1.0), for: .normal)
        subAlertButton2.titleLabel!.textAlignment = .center
        subAlertButton2.setTitle("Set", for: .normal)
        subAlertButton2.backgroundColor = UIColor.clear
        subAlertButton2.setTitleColor(UIColor(red: 0.0, green: 0.4, blue: 1.0, alpha: 1.0), for: .normal)
        subAlertButton1.addTarget(self, action: #selector(setTUIC11), for: .touchUpInside)
        subAlertButton1.addTarget(self, action: #selector(setTUOC11), for: .touchUpOutside)
        subAlertButton2.addTarget(self, action: #selector(setTDC11), for: .touchDown)
        subAlertButton2.addTarget(self, action: #selector(setTUIC11), for: .touchUpInside)
        subAlertButton2.addTarget(self, action: #selector(setTUOC11), for: .touchUpOutside)
        subAlertButton1.layer.borderColor = UIColor.darkGray.cgColor
        subAlertButton1.layer.borderWidth = 0.3
        subAlertButton2.layer.borderColor = UIColor.darkGray.cgColor
        subAlertButton2.layer.borderWidth = 0.3
        subAlertButton1.clipsToBounds = true
        alertRect.addSubview(subAlertButton1)
        alertRect.addSubview(subAlertButton2)

        blurRect.isHidden = true
        alertRect.isHidden = true
    }

    func positionSubThreeA() {
        blurRect.frame = view.bounds
        BlurButton.frame = blurRect.bounds
        alertRect.frame = CGRect(x: 0, y: 0, width: 270, height: 320 / 5 * 3)
        alertRect.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        subAlertTitle.frame = CGRect(x: 0, y: 0, width: alertRect.bounds.width, height: alertRect.bounds.height / 10 * 2)
        subAlertLabel1.frame = CGRect(x: 0, y: alertRect.bounds.height / 10 * 2.5, width: alertRect.bounds.width / 6, height: alertRect.bounds.height / 10)
        subAlertLabel2.frame = CGRect(x: 0, y: alertRect.bounds.height / 10 * 4.5, width: alertRect.bounds.width / 6, height: alertRect.bounds.height / 10)
        subAlertLabel3.frame = CGRect(x: 0, y: alertRect.bounds.height / 10 * 6.5, width: alertRect.bounds.width / 6, height: alertRect.bounds.height / 10)
        subAlertSlider1.frame = CGRect(x: subAlertLabel1.bounds.width * 1.5, y: subAlertLabel1.frame.minY, width: alertRect.bounds.width / 6 * 4, height: alertRect.bounds.height / 10)
        subAlertSlider2.frame = CGRect(x: subAlertLabel2.bounds.width * 1.5, y: subAlertLabel2.frame.minY, width: alertRect.bounds.width / 6 * 4, height: alertRect.bounds.height / 10)
        subAlertSlider3.frame = CGRect(x: subAlertLabel3.bounds.width * 1.5, y: subAlertLabel3.frame.minY, width: alertRect.bounds.width / 6 * 4, height: alertRect.bounds.height / 10)
        subAlertButton1.frame = CGRect(x: 0, y: 0, width: alertRect.bounds.width / 2, height: alertRect.bounds.height / 10 * 2)
        subAlertButton1.center = CGPoint(x: alertRect.bounds.width / 4, y: alertRect.bounds.height / 10 * 9)
        subAlertButton2.frame = CGRect(x: 0, y: 0, width: alertRect.bounds.width / 2, height: alertRect.bounds.height / 10 * 2)
        subAlertButton2.center = CGPoint(x: alertRect.bounds.width / 4 * 3 + 0.1, y: alertRect.bounds.height / 10 * 9)
    }

    @IBAction func blurTUI(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.blurRect.isHidden = true
            self.alertRect.isHidden = true
        }
    }

    @IBAction func alertSliderChanged(_ sender: UISlider) {
        DispatchQueue.main.async {
            print(sender.value)
            self.subAlertTitle.backgroundColor = UIColor(red: CGFloat(self.subAlertSlider1.value), green: CGFloat(self.subAlertSlider2.value), blue: CGFloat(self.subAlertSlider3.value), alpha: 1.0)
        }
    }

    @IBAction func setTDC11(_ sender: UIButton) {
        DispatchQueue.main.async {
            sender.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        }
    }

    @IBAction func setTUOC11(_ sender: UIButton) {
        DispatchQueue.main.async {
            sender.backgroundColor = UIColor.clear
        }
    }

    @IBAction func setTUIC11(_ sender: UIButton) {
        DispatchQueue.main.async {
            sender.backgroundColor = UIColor.clear
            if sender == self.subAlertButton2 {
                self.ColorRGB = [CGFloat(self.subAlertSlider1.value), CGFloat(self.subAlertSlider2.value), CGFloat(self.subAlertSlider3.value)]
                self.setTUIC11_add()
            }
            self.blurRect.isHidden = true
            self.alertRect.isHidden = true
        }
    }

    func setTUIC11_add() {}

    @IBAction func setTUIT(_ sender: UIButton) {
        subAlertSlider1.value = Float(ColorRGB[0])
        subAlertSlider2.value = Float(ColorRGB[1])
        subAlertSlider3.value = Float(ColorRGB[2])
        subAlertTitle.backgroundColor = UIColor(red: ColorRGB[0], green: ColorRGB[1], blue: ColorRGB[2], alpha: 1.0)
        blurRect.isHidden = false
        alertRect.isHidden = false
    }
}
