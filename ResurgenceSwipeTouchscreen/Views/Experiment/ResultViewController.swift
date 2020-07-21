//
//  ResultViewController.swift
//
//  Created by Yuto Mizutani on 2017/01/19.
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

import SwiftyDropbox
import UIKit

private let ballPieRadius = screenWidth * 2 / 3

class ResultViewController: UIViewController {
    /// 現在のデータがアップロード済みかどうか
    static var didUpload: Bool = false

    let labelTitle = UILabel(frame: CGRect(x: 0, y: screenHeight / 20 / 2, width: screenWidth, height: screenHeight / 10 - 25)) // rect.bounds)
    let cRect: UIView = UIView(frame: CGRect(x: 0, y: screenHeight / 20 * 3, width: screenWidth, height: screenHeight - (screenHeight / 20 + screenHeight / 10 * 2)))
    let pieCircle: UIView = UIView(frame: CGRect(x: 0, y: 0, width: ballPieRadius, height: ballPieRadius))
    private lazy var buttonC: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    private lazy var angleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    private lazy var phaseButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var numOfPara: Int = 20 // 360 //Pie graphの枝数(1-360)

    let swipeAngle = BallStoreData.swipeAngle
    var currentPhaseNum: Int = 0 // 0: all, else: phase
    let storedPhases: [PhaseValue] = ExperimentViewController.storedValue.phases
    var radiusBool: Bool = true // true:全反応数を100%, false:最大反応数を100%

    override func viewDidLoad() {
        super.viewDidLoad()
        print(swipeAngle)

        ResultViewController.didUpload = false
        layoutcRect()
        layoutBRect()
        layoutRect()
        layoutPieRect()

        print(view.subviews)
        textRead()

        angleWriting()
        labelTitle.text = "Result"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        saveFunc()
        uploadFunc()
    }

    func saveFunc() {
        let saveResult = BallStoreDataX.textWriting(storedParameter: ExperimentViewController.storedParameter)
        if saveResult.isResult {
            let alert = UIAlertController(
                title: "Success: Save data",
                message: "FileName: \(saveResult.fileName)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Done", style: .default) { (_: UIAlertAction!) -> Void in
            })
            present(alert, animated: true, completion: nil)
        }
    }

    func uploadFunc() {
        print("uploadfunc()")
        BallStoreDataX.textUploadDropbox(self, storedParameter: ExperimentViewController.storedParameter)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !ResultViewController.didUpload {
            BallStoreDataX.uploadErrorFilesSaving(storedParameter: ExperimentViewController.storedParameter)
        }
    }

    private func layoutRect() {
        // DropboxLoginButton
        let size: CGFloat = 75
        let button = UIButton(frame: CGRect(x: screenWidth - size - 10, y: statusbarHeight + 10, width: size, height: size))
        // button.setTitle("Dropbox", for: .normal)
        // button.setTitleColor(UIColor.blue, for: .normal)
        // button.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight/40)
        // button.titleLabel?.textAlignment = NSTextAlignment.right
        button.setImage(UIImage(named: "02"), for: .normal)
        button.tag = 1
        button.addTarget(self, action: #selector(setTUITR), for: .touchUpInside)
        view.addSubview(button)
        let iview = UIImageView(frame: CGRect(x: screenWidth - size - 10 + 5, y: statusbarHeight + 10 + 5, width: size - 5 * 2, height: size - 5 * 2))
        iview.isUserInteractionEnabled = false
        iview.image = UIImage(named: "dropbox-ios")
        view.addSubview(iview)

        labelTitle.text = "Result"
        labelTitle.textAlignment = NSTextAlignment.center
        labelTitle.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2)
        view.addSubview(labelTitle)
    }

    private func layoutcRect() {
        // let CRRect:UIView = UIView(frame:CGRect(x:0, y:screenHeight/20+screenHeight/10, width:screenWidth, height:screenHeight-(screenHeight/20+screenHeight/10*2)))
        cRect.isUserInteractionEnabled = true // ユーザーによるタッチを許可→デフォルトではfalse
        let textView: UITextView = UITextView(frame: CGRect(x: screenWidth / 10, y: 0, width: screenWidth - screenWidth / 10 * 2, height: cRect.bounds.height * 9 / 10 - screenHeight / 20))
        textView.tag = 12
        // 複数行のTextViewに枠を付加
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor // (red: 0, green: 255/2, blue: 255/2, alpha: 1.0).cgColor//
        textView.layer.cornerRadius = 8
        textView.isEditable = false // 編集不可
        textView.textAlignment = NSTextAlignment.left
        cRect.addSubview(textView)

        let button: UIButton = UIButton(frame: CGRect(x: screenWidth / 10 * 1, y: cRect.bounds.height * 9 / 10 - screenHeight / 20 + 25, width: screenWidth / 10 * 3, height: cRect.bounds.height - 50 - (cRect.bounds.height * 9 / 10 - screenHeight / 20)))
        button.tag = 2
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(setTUIB), for: .touchUpInside)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 40)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor // UIColor(red: 0, green: 255/2, blue: 255/2, alpha: 1.0).cgColor//lightGray.cgColor;
        button.layer.cornerRadius = 8
        cRect.addSubview(button)
        let buttonUpload: UIButton = UIButton(frame: CGRect(x: screenWidth / 10 * 4.5, y: cRect.bounds.height * 9 / 10 - screenHeight / 20 + 25, width: screenWidth / 10 * 3, height: cRect.bounds.height - 50 - (cRect.bounds.height * 9 / 10 - screenHeight / 20)))
        buttonUpload.tag = 3
        buttonUpload.setTitle("Dropbox", for: .normal)
        buttonUpload.addTarget(self, action: #selector(setTUIB), for: .touchUpInside)
        buttonUpload.setTitleColor(UIColor.blue, for: .normal)
        buttonUpload.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 40)
        buttonUpload.layer.borderWidth = 1
        buttonUpload.layer.borderColor = UIColor.lightGray.cgColor // UIColor(red: 0, green: 255/2, blue: 255/2, alpha: 1.0).cgColor//lightGray.cgColor;
        buttonUpload.layer.cornerRadius = 8
        cRect.addSubview(buttonUpload)

        // angle change
        angleButton = UIButton(frame: CGRect(x: screenWidth / 10 * 1, y: cRect.bounds.height * 9 / 10 - screenHeight / 20 + 25, width: screenWidth / 10 * 2.5, height: cRect.bounds.height - 50 - (cRect.bounds.height * 9 / 10 - screenHeight / 20)))
        angleButton.setTitle("Segment", for: .normal)
        angleButton.addTarget(self, action: #selector(setTUIA), for: .touchUpInside)
        angleButton.setTitleColor(UIColor.blue, for: .normal)
        angleButton.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 40)
        angleButton.layer.borderWidth = 1
        angleButton.layer.borderColor = UIColor.lightGray.cgColor // UIColor(red: 0, green: 255/2, blue: 255/2, alpha: 1.0).cgColor//lightGray.cgColor;
        angleButton.backgroundColor = UIColor.white
        angleButton.layer.cornerRadius = 8
        cRect.addSubview(angleButton)

        // phase change
        phaseButton = UIButton(frame: CGRect(x: screenWidth / 10 * 4, y: cRect.bounds.height * 9 / 10 - screenHeight / 20 + 25, width: screenWidth / 10 * 2.5, height: cRect.bounds.height - 50 - (cRect.bounds.height * 9 / 10 - screenHeight / 20)))
        phaseButton.setTitle("Phase: All", for: .normal)
        phaseButton.addTarget(self, action: #selector(setTUIAP), for: .touchUpInside)
        phaseButton.setTitleColor(UIColor.blue, for: .normal)
        phaseButton.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 40)
        phaseButton.layer.borderWidth = 1
        phaseButton.layer.borderColor = UIColor.lightGray.cgColor // UIColor(red: 0, green: 255/2, blue: 255/2, alpha: 1.0).cgColor//lightGray.cgColor;
        phaseButton.backgroundColor = UIColor.white
        phaseButton.layer.cornerRadius = 8
        cRect.addSubview(phaseButton)

        let h: CGFloat = cRect.frame.height - 50 - (cRect.bounds.height * 9 / 10 - screenHeight / 20)
        buttonC = UIButton(frame: CGRect(x: screenWidth / 10 * 8 - h * 5 / 4, y: cRect.bounds.height * 9 / 10 - screenHeight / 20 + 25, width: h, height: h))
        buttonC.setImage(UIImage(named: "settings"), for: .normal)
        buttonC.tag = 1990
        buttonC.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        cRect.addSubview(buttonC)

        let buttonI = UIButton(frame: CGRect(x: screenWidth / 10 * 8, y: cRect.bounds.height * 9 / 10 - screenHeight / 20 + 25, width: h, height: h)) // (frame:CGRect(x:screenWidth-10-60-60-60-60, y:statusbarHeight+10, width:50, height:50))
        // buttonI.center = CGPoint(x:angleButton.frame.maxX+buttonI.bounds.width, y:angleButton.frame.maxY+buttonI.bounds.height/2)//layoutcRectが上
        buttonI.setImage(UIImage(named: "info"), for: .normal)
        buttonI.tag = 2000
        buttonI.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        cRect.addSubview(buttonI)

        view.addSubview(cRect)

        // textView.isHidden = true
        buttonC.isHidden = true
        angleButton.isHidden = true
        phaseButton.isHidden = true
        // buttonI.isHidden = true
    }

    private func layoutPieRect() {
        pieCircle.isUserInteractionEnabled = false // ユーザーによるタッチを許可→デフォルトではfalse
        pieCircle.backgroundColor = UIColor.clear
        pieCircle.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        pieCircle.backgroundColor = UIColor.white
        pieCircle.layer.cornerRadius = pieCircle.bounds.width / 2 // viewを円に
        pieCircle.clipsToBounds = true // 範囲外を描画しない
        pieCircle.layer.borderColor = UIColor.lightGray.cgColor
        pieCircle.layer.borderWidth = 1.0

        view.addSubview(pieCircle)
        pieCircle.isHidden = true
    }

    private func layoutBRect() {
        let rect: UIView = UIView(frame: CGRect(x: 0, y: screenHeight / 10 * 9, width: screenWidth, height: screenHeight / 10))
        rect.isUserInteractionEnabled = true // ユーザーによるタッチを許可→デフォルトではfalse
        rect.backgroundColor = UIColor.lightGray

        let button: UIButton = UIButton(frame: rect.bounds)
        button.setTitle("Finish", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 40)
        button.tag = 10
        button.addTarget(self, action: #selector(setTUIB), for: .touchUpInside)
        button.setTitleColor(UIColor.blue, for: .normal)
        rect.addSubview(button)

        view.addSubview(rect)
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

    @IBAction private func setTUI(sender: UIButton) {
        switch sender.tag {
        case 1990:
            radiusBool.toggle()
            angleWriting(currentPhaseNum)
        case 2000:
            if pieCircle.isHidden {
                angleWriting()
            } else {
                labelTitle.text = "Result"
            }
            buttonC.isHidden.toggle()
            pieCircle.isHidden.toggle()
            angleButton.isHidden.toggle()
            phaseButton.isHidden.toggle()
            view.viewWithTag(2)?.isHidden = !view.viewWithTag(2)!.isHidden
            view.viewWithTag(3)?.isHidden = !view.viewWithTag(3)!.isHidden
            view.viewWithTag(12)!.isHidden = !view.viewWithTag(12)!.isHidden
        default:
            break
        }
    }

    @IBAction private func setTUIAP(sender: UIButton) {
        do {
            var phaseStr: String = "All"
            if currentPhaseNum < storedPhases.count {
                // phaseがカウント（存在しない値）を超えない場合は+1
                currentPhaseNum += 1
                phaseStr = "\(currentPhaseNum)"
            } else {
                // そうでない場合は0(all)を参照
                currentPhaseNum = 0
            }
            DispatchQueue.main.async {
                self.phaseButton.setTitle("Phase: \(phaseStr)", for: .normal)
            }
        }

        angleWriting(currentPhaseNum)
    }

    @IBAction private func setTUIA(sender: UIButton) {
        UpdateAngle()
    }

    func UpdateAngle() {
        let alert = UIAlertController(
            title: "Update segment",
            message: "Default: 20, Now: " + numOfPara.description,
            preferredStyle: .alert
        )
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.text = self.numOfPara.description
        }
        let textField = alert.textFields![0] as UITextField
        alert.addAction(UIAlertAction(title: "Done", style: .default) { (_: UIAlertAction!) -> Void in
            if textField.text == "" {
                let alert = UIAlertController(
                    title: "Warning",
                    message: "TextField is empty",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default) { (_: UIAlertAction!) -> Void in
                    self.UpdateAngle()
                })
                self.present(alert, animated: true, completion: nil)
            } else {
                if self.NumCheck(str: textField.text!) {
                    if Int(textField.text!)! >= 1, Int(textField.text!)! <= 360 {
                        self.numOfPara = Int(textField.text!)!
                        self.angleWriting()
                    } else {
                        let alert = UIAlertController(
                            title: "Warning",
                            message: "Parameter range is \"1 to 360\".",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_: UIAlertAction!) -> Void in
                            self.UpdateAngle()
                        })
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(
                        title: "Warning",
                        message: "You can use \"0-9\".",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { (_: UIAlertAction!) -> Void in
                        self.UpdateAngle()
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }

    private func NumCheck(str: String) -> Bool {
        for i in str {
            switch i {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                break
            default:
                return false
            }
        }
        return true
    }

    @IBAction private func setTUIB(sender: UIButton) {
        switch sender.tag {
        case 2:
            saveFunc()
        case 3:
            uploadFunc()
        case 10:
            returnViewFunc()
        default:
            break
        }
    }

    func returnViewFunc() {
        func returnView() {
            // popToRootViewController
            let viewController = ViewController()
            viewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            present(viewController, animated: true, completion: nil)
        }
        if ResultViewController.didUpload {
            returnView()
        } else {
            let alert = UIAlertController(
                title: "Warning",
                message: "Are you sure to leave without uploading a data file to Dropbox?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Leave", style: .default) { (_: UIAlertAction!) -> Void in
                let errorSave = BallStoreDataX.uploadErrorFilesSaving(storedParameter: ExperimentViewController.storedParameter)
                if errorSave.isResult {
                    do {
                        let alert = UIAlertController(
                            title: "Data not uoloaded yet",
                            message: "You can manually upload later.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Finish", style: .default) { (_: UIAlertAction!) -> Void in
                            returnView()
                        })
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    do {
                        let alert = UIAlertController(
                            title: "Error files cannot saved...",
                            message: "Are you retry saving?",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Finish", style: .default) { (_: UIAlertAction!) -> Void in
                            returnView()
                        })
                        alert.addAction(UIAlertAction(title: "Retry", style: .cancel) { (_: UIAlertAction!) -> Void in
                            self.returnViewFunc()
                        })
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            alert.addAction(UIAlertAction(title: "Stay", style: .cancel) { (_: UIAlertAction!) -> Void in
            })
            present(alert, animated: true, completion: nil)
        }
    }

    private func textRead() {
        let textView: UITextView = cRect.viewWithTag(12) as! UITextView
        let a = BallStoreDataX()
        a.endWrite(storedParameter: ExperimentViewController.storedParameter, storedValue: ExperimentViewController.storedValue)
        print("textRead()")
        textView.text = BallStoreDataX.rawDataString
    }

    private func angleWriting(_ phaseNum: Int = 0) {
        phaseButton.setTitle("Phase: All", for: .normal)

        for i in pieCircle.subviews {
            i.removeFromSuperview()
        }

        let auxiliaryLineBool: Bool = true // 補助線
        let isTopZero: Bool = false // 補助線の上を0にする=-90する
        let minS: CGFloat = ballPieRadius / 2 / 50

        // 使用するangleを取得
        var drawAngleArray: [Int] = phaseNum == 0 ? swipeAngle : storedPhases[phaseNum - 1].allAngles
        var allSwipes: Int = 0
        for i in 0 ... drawAngleArray.count - 1 {
            let x: Int = drawAngleArray[i]
            if radiusBool {
                allSwipes += x
            } else {
                if allSwipes < x {
                    allSwipes = x
                }
            }
            print("Phase(\(phaseNum)) drawAngleArray[\(i)]: \(drawAngleArray[i]), allSwipes: \(allSwipes)")
        }

        if auxiliaryLineBool {
            let auxiliaryLineView = UIView(frame: pieCircle.bounds)
            auxiliaryLineView.center = CGPoint(x: pieCircle.bounds.width / 2, y: pieCircle.bounds.width / 2)
            let auxiliaryLine = UIBezierPath()
            let auxiliaryViewLayer = CAShapeLayer()
            auxiliaryViewLayer.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1).cgColor
            auxiliaryViewLayer.lineWidth = 1.0

            for i in 1 ... numOfPara {
                auxiliaryLine.move(to: CGPoint(x: ballPieRadius / 2, y: ballPieRadius / 2))
                var anglei = 360 / numOfPara * i
                if isTopZero {
                    anglei -= 90
                }
                let s: CGFloat = ballPieRadius / 2
                // 斜辺*CosΘ
                let x: CGFloat = s * CGFloat(cos(Double(anglei) * Double.pi / 180.0))
                // 斜辺
                let y: CGFloat = x * CGFloat(tan(Double(anglei) * Double.pi / 180.0))
                auxiliaryLine.addLine(to: CGPoint(x: ballPieRadius / 2 + x, y: ballPieRadius / 2 - y))
            }
            auxiliaryLine.close()

            auxiliaryViewLayer.path = auxiliaryLine.cgPath
            auxiliaryLineView.layer.addSublayer(auxiliaryViewLayer)
            pieCircle.addSubview(auxiliaryLineView)
        }

        if numOfPara == 360 {
            let lineView = UIView(frame: pieCircle.bounds)
            lineView.center = CGPoint(x: pieCircle.bounds.width / 2, y: pieCircle.bounds.width / 2) // pieRect.center
            let line = UIBezierPath()
            let viewLayer = CAShapeLayer()
            viewLayer.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor // UIColor.blue.cgColor
            viewLayer.fillColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
            viewLayer.lineWidth = 2.0

            let angle0360: Int = (drawAngleArray[0] + drawAngleArray[360]) / allSwipes // https://www.nukoneko.info/blog/?p=483
            line.move(to: CGPoint(x: ballPieRadius / 2, y: ballPieRadius / 2 - CGFloat(angle0360) * ballPieRadius / 2))
            for i in 1 ... drawAngleArray.count - 2 {
                let anglei: Double = Double(drawAngleArray[i]) / Double(allSwipes)

                print(i.description + ":" + anglei.description)
                // http://keisan.casio.jp/exec/system/1177474036
                if drawAngleArray[i] != 0 {
                    let S: CGFloat = CGFloat(anglei) * ballPieRadius / 2
                    let X: CGFloat = S * CGFloat(cos(Double(i) * Double.pi / 180.0)) // 斜辺*CosΘ
                    let Y: CGFloat = X * CGFloat(tan(Double(i) * Double.pi / 180.0)) // CGFloat(Double(CGFloat(anglei)*ballPieRadius/2)/sin(Double(i/180)*Double.pi)) //斜辺
                    print("i:" + i.description + ", num:" + drawAngleArray[i].description + ", all:" + allSwipes.description + ", S:" + S.description + ", X:" + X.description + ", Y:" + Y.description)
                    line.addLine(to: CGPoint(x: ballPieRadius / 2 + X, y: ballPieRadius / 2 - Y))
                } else {
                    line.addLine(to: CGPoint(x: ballPieRadius / 2, y: ballPieRadius / 2))
                }
            }
            line.addLine(to: CGPoint(x: ballPieRadius / 2, y: ballPieRadius / 2 - CGFloat(angle0360) * ballPieRadius / 2))
            line.close()

            viewLayer.path = line.cgPath
            lineView.layer.addSublayer(viewLayer)
            pieCircle.addSubview(lineView)
        } else {
            let lineView = UIView(frame: pieCircle.bounds)
            lineView.center = CGPoint(x: pieCircle.bounds.width / 2, y: pieCircle.bounds.width / 2)
            let line = UIBezierPath()
            let viewLayer = CAShapeLayer()
            viewLayer.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
            viewLayer.fillColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
            viewLayer.lineWidth = 2.0

            let angleOne: Double = 360.0 / Double(numOfPara)

            if !isTopZero {
                var pieRadiuslen: Int = 0
                if !radiusBool {
                    var angle0: Double = 0
                    for x in 0 ... drawAngleArray.count - 1 {
                        if (Double(x) <= angleOne / 2) || (Double(x) >= (360 - angleOne / 2)) {
                            angle0 += Double(drawAngleArray[x])
                        }
                    }
                    if allSwipes < Int(angle0) {
                        allSwipes = Int(angle0)
                    }
                    for i in 1 ..< numOfPara {
                        var anglei: Double = 0
                        for x in 0 ... drawAngleArray.count - 1 {
                            if Double(x) >= angleOne * Double(i) - angleOne / 2, Double(x) <= angleOne * Double(i) + angleOne / 2 {
                                anglei += Double(drawAngleArray[x])
                            }
                        }
                        if allSwipes < Int(anglei) {
                            allSwipes = Int(anglei)
                        }
                    }
                }

                // ひとつめ
                var angle0: Double = 0
                for x in 0 ... drawAngleArray.count - 1 {
                    if (Double(x) <= angleOne / 2) || (Double(x) >= (360 - angleOne / 2)) {
                        angle0 += Double(drawAngleArray[x])
                    }
                }
                pieRadiuslen = Int(angle0)
                var x: CGFloat = 0
                var y: CGFloat = 0
                if angle0 != 0 {
                    angle0 /= Double(allSwipes)

                    let s: CGFloat = CGFloat(angle0) * ballPieRadius / 2
                    // 斜辺*CosΘ
                    x = s * CGFloat(cos(Double(0) * Double.pi / 180.0))
                    // 斜辺
                    y = x * CGFloat(tan(Double(0) * Double.pi / 180.0))

                    line.move(to: CGPoint(x: ballPieRadius / 2 + x, y: ballPieRadius / 2 - y))
                } else {
                    let s: CGFloat = minS
                    // 斜辺*CosΘ
                    x = s * CGFloat(cos(Double(0) * Double.pi / 180.0))
                    // 斜辺
                    y = x * CGFloat(tan(Double(0) * Double.pi / 180.0))

                    line.move(to: CGPoint(x: ballPieRadius / 2 + x, y: ballPieRadius / 2 - y))
                }

                for i in 1 ..< numOfPara {
                    var anglei: Double = 0

                    for x in 0 ... drawAngleArray.count - 1 {
                        if Double(x) >= angleOne * Double(i) - angleOne / 2, Double(x) <= angleOne * Double(i) + angleOne / 2 {
                            anglei += Double(drawAngleArray[x])
                        }
                    }
                    if radiusBool {
                        pieRadiuslen += Int(anglei)
                    } else {
                        if pieRadiuslen < Int(anglei) {
                            pieRadiuslen = Int(anglei)
                        }
                    }

                    if anglei != 0 {
                        anglei /= Double(allSwipes)

                        let S: CGFloat = CGFloat(anglei) * ballPieRadius / 2
                        let X: CGFloat = S * CGFloat(cos(Double(angleOne * Double(i)) * Double.pi / 180.0)) // 斜辺*CosΘ
                        // 斜辺
                        let Y: CGFloat = X * CGFloat(tan(Double(angleOne * Double(i)) * Double.pi / 180.0))

                        line.addLine(to: CGPoint(x: ballPieRadius / 2 + X, y: ballPieRadius / 2 - Y))
                    } else {
                        let s: CGFloat = minS
                        // 斜辺*CosΘ
                        let x: CGFloat = s * CGFloat(cos(Double(angleOne * Double(i)) * Double.pi / 180.0))
                        // 斜辺
                        let y: CGFloat = x * CGFloat(tan(Double(angleOne * Double(i)) * Double.pi / 180.0))

                        line.addLine(to: CGPoint(x: ballPieRadius / 2 + x, y: ballPieRadius / 2 - y))
                    }
                }
                line.addLine(to: CGPoint(x: ballPieRadius / 2 + x, y: ballPieRadius / 2 - y))
                line.close()

                viewLayer.path = line.cgPath
                lineView.layer.addSublayer(viewLayer)
                pieCircle.addSubview(lineView)

                let xx: Int = drawAngleArray.reduce(0) { $0 + $1 }
                // radiusBool == true は //true:全反応数を100%, false:最大反応数を100%
                labelTitle.text = radiusBool ? "% of total swipes: \(xx)" : "% of most frequent swipes: \(pieRadiuslen)"
            }
        }
    }
}

extension ResultViewController {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("self.view.subviews.count: \(view.subviews.count)")
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        print("self.view.subviews.count: \(view.subviews.count)")

        removeVariables()

        view = nil
    }

    func removeVariables() {
        ExperimentViewController.storedParameter = StoredEmptyParameter()
        ExperimentViewController.storedValue = StoredValue(firstTargetAngle: 0)
    }
}
