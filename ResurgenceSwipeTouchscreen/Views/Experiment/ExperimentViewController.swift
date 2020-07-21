//
//  ExperimentViewController.swift
//
//  Created by Yuto Mizutani on 2017/03/27.
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

import CoreMotion
import QuartzCore
import SceneKit
import UIKit

import OperantKit
import RxCocoa
import RxSwift

class ExperimentViewController: UIViewController {
    private var timerUseCase: TimerUseCase = WhileLoopTimerUseCase(priority: .high)
    private var isReinforcement: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    var reinforcementOnTime: PublishRelay<Int> = PublishRelay()
    private var reinforcementOffTime: PublishRelay<Int> = PublishRelay()
    private var reinforcementTime: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    var allRealTime: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    private var allSessionTime: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    private var currentPhaseRealTime: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    private var currentPhaseSessionTime: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    private var phaseValueWhenPreviousPhase: (startRealTime: Int, startSesisonTime: Int) = (0, 0)
    private var disposeBag = DisposeBag()
    private var currentPhaseDisposeBag = DisposeBag()

    private func binding() {
        timerUseCase = WhileLoopTimerUseCase(priority: .high)
        reinforcementTime = BehaviorRelay<Int>(value: 0)
        allRealTime = BehaviorRelay<Int>(value: 0)
        allSessionTime = BehaviorRelay<Int>(value: 0)
        currentPhaseRealTime = BehaviorRelay<Int>(value: 0)
        currentPhaseSessionTime = BehaviorRelay<Int>(value: 0)
        phaseValueWhenPreviousPhase = (0, 0)
        disposeBag = DisposeBag()
        currentPhaseDisposeBag = DisposeBag()

        let time: Observable<(realTime: Int, sessionTime: Int)> = timerUseCase.milliseconds
            .distinctUntilChanged()
            .map { (realTime: $0, sessionTime: $0 - self.reinforcementTime.value) }
            .share(replay: 1)

        time.map { $0.realTime }
            .bind(to: allRealTime)
            .disposed(by: disposeBag)

        time.map { $0.sessionTime }
            .filter { _ in !self.isReinforcement.value }
            .bind(to: allSessionTime)
            .disposed(by: disposeBag)

        allRealTime.map { $0 - self.phaseValueWhenPreviousPhase.startRealTime }
            .bind(to: currentPhaseRealTime)
            .disposed(by: disposeBag)

        allSessionTime.map { $0 - self.phaseValueWhenPreviousPhase.startSesisonTime }
            .bind(to: currentPhaseSessionTime)
            .disposed(by: disposeBag)

        Observable.merge(reinforcementOnTime.map { _ in true },
                         reinforcementOffTime.map { _ in false })
            .bind(to: isReinforcement)
            .disposed(by: disposeBag)

        Observable.zip(reinforcementOnTime, reinforcementOffTime)
            .map { $0.1 - $0.0 }
            .subscribe(onNext: { [unowned self] in
                self.reinforcementTime.accept(self.reinforcementTime.value + $0)
            })
            .disposed(by: disposeBag)

        // End with session time
        if ExperimentViewController.storedParameter.sessionTimeMin > 0 {
            allSessionTime
                .filter { ExperimentViewController.storedParameter.sessionTimeMin * 60 * 1000 <= $0 }
                .take(1)
                .debug()
                .subscribe { [weak self] _ in
                    self?.EndSession()
                }
                .disposed(by: disposeBag)
        }
    }

    fileprivate var scnView: ExperimentSCNView?
    fileprivate var scnScene: SCNScene? = SCNScene(named: "soccerball.dae")!
    let cameraNode = SCNNode()

    static var storedParameter: StoredParameterable = StoredEmptyParameter()
    static var storedValue: StoredValuable = StoredValue(firstTargetAngle: 0)

    var isFinished: Bool = false

    var firstSwipeAngle: Int = 9999
    var logLabel: UILabel?
    var rftOnBool: Bool = false
    var numTouch: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        for i in view.subviews {
            i.removeFromSuperview()
        }
        scnView = ExperimentSCNView(self)
        scnView?.tag = 5000
        scnView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width)
        scnView?.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        scnView?.layer.borderColor = UIColor.darkGray.cgColor
        scnView?.layer.borderWidth = 1.5

        scnView?.scene = scnScene

        scnView?.allowsCameraControl = true
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 2.5)
        cameraNode.rotateUp(by: 90 + (-20 * (.pi / 180)))
        scnScene?.rootNode.addChildNode(cameraNode)
        scnView?.pointOfView = cameraNode
        SCNTransaction.commit()

        let half = Float(2) // 2)
        let vertices = [
            SCNVector3(-half, +half, +half),
            SCNVector3(+half, +half, +half),
            SCNVector3(-half, -half, +half),
            SCNVector3(+half, -half, +half),
            SCNVector3(-half, +half, -half),
            SCNVector3(+half, +half, -half),
            SCNVector3(-half, -half, -half),
            SCNVector3(+half, -half, -half)
        ]

        for i in 0 ..< vertices.count {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = .omni
            lightNode.position = vertices[i]
            scnScene?.rootNode.addChildNode(lightNode)
        }

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.gray
        scnScene?.rootNode.addChildNode(ambientLightNode)

        let doublePanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(doublePanHandler))
        doublePanRecognizer.minimumNumberOfTouches = 2
        doublePanRecognizer.maximumNumberOfTouches = 100
        scnView?.addGestureRecognizer(doublePanRecognizer)

        let doublePinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(doublePinchHandler))
        scnView?.addGestureRecognizer(doublePinchRecognizer)

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scnView?.addGestureRecognizer(doubleTapRecognizer)

        scnView?.backgroundColor = UIColor.clear

        view.addSubview(scnView!)
        layoutUPRect()
        layoutRect()
        layoutTRRect()
        layoutBRRect()

        layoutBackRect()
        layoutStarRect()

        binding()
        StartSetting()
        StartSession()
        do {
            // MARK: storedValueの最初の角度を変更する場合はこの初期化を使用

            /// userAngle がnil時に最初の反応を強化する設定を追加。 2018/01/15 ym add
            ExperimentViewController.storedValue = StoredValue(firstTargetAngle: ExperimentViewController.storedParameter.getCurrentPhases(1).userAngle ?? 999, isEXT: ExperimentViewController.storedParameter.getCurrentPhases(1).schedule == .EXT)
            nextTimer(ExperimentViewController.storedParameter)
            renewalLabel()
        }
    }

    func EndAlert() {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: "Session finished", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addTextField(configurationHandler: { (textf: UITextField!) -> Void in
                textf.isSecureTextEntry = true
            })
            let defaultAct: UIAlertAction = UIAlertAction(title: "Enter", style: UIAlertAction.Style.default, handler: {
                (_: UIAlertAction!) -> Void in
                let textf = alert.textFields![0] as UITextField
                print("F:" + textf.text! + "P:" + ExperimentViewController.storedParameter.password)
                if textf.text == ExperimentViewController.storedParameter.password {
                    StoreData.listData += "PasswordCorrect: \(self.allRealTime.value)\n"
                    DispatchQueue.main.async {
                        let viewController = ResultViewController()
                        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        self.timerUseCase.finish().subscribe().disposed(by: self.disposeBag)
                        self.present(viewController, animated: true, completion: nil)
                    }
                } else {
                    StoreData.listData += "PasswordIncorrect: \(self.allRealTime.value)\n"
                    self.EndAlert()
                }
            })
            alert.addAction(defaultAct)
            self.present(alert, animated: true, completion: nil)
            self.view.endEditing(true)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan! called")
        numTouch += 1
        if numTouch >= 2, starAllRect.isHidden {
            print("double tap")
            BallStoreData.doubleTapAlertNum += 1
            ExperimentViewController.storedValue.getCurrentPhases().doubleTapResp += 1
            StoreData.listData += BallStoreData.doubleTapID + ": \(allRealTime.value)\n"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.numTouch = 0
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        numTouch = 0
    }

    func tapHandler(sender: UITapGestureRecognizer) {
        print("Tap")
    }

    @objc func doubleTapHandler(sender: UITapGestureRecognizer) {
        print("DoubleTap")
    }

    func swipeHandler(sender: UISwipeGestureRecognizer) {
        print("Swipe")
    }

    func doubleSwipeHandler(sender: UISwipeGestureRecognizer) {
        print("DoubleSwipe")
    }

    func panHandler(sender: UIPanGestureRecognizer) {
        print("Pan")
    }

    @objc func doublePanHandler(sender: UIPanGestureRecognizer) {
        print("DoublePan")
    }

    @objc func doublePinchHandler(sender: UIPinchGestureRecognizer) {
        print("DoublePinch")
    }

    private lazy var swipeRect: UIView = self.createRect(widthA: 0, heightA: 0)
    private lazy var logRect = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth / 4, height: screenWidth / 4))
    private lazy var logSwipeView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth / 4, height: screenWidth / 4))
    private lazy var backRect: UIView = self.createRect(widthA: screenWidth / 2, heightA: screenHeight / 2)
    private lazy var TRRect: UIView = self.createRect(widthA: screenWidth / 2, heightA: screenHeight / 2)
    private lazy var BRRect: UIView = self.createRect(widthA: screenWidth / 2, heightA: screenHeight / 2)
    private lazy var circleRect: UIView = UIView(frame: CGRect(x: 0, y: (screenHeight - screenWidth) / 2, width: screenWidth, height: screenWidth))
    var starRect = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth / 4, height: screenWidth / 4))
    var starAllRect = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    fileprivate var underPointView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    private func createRect(widthA: CGFloat, heightA: CGFloat) -> UIView {
        var widthX = widthA
        var heightX = heightA
        if widthA == 0 { widthX = screenWidth }
        if heightA == 0 { heightX = screenHeight }
        let rect = UIView(frame: CGRect(x: 0, y: 0, width: widthX, height: heightX))
        rect.isUserInteractionEnabled = true
        return rect
    }

    var allResp: Int = 0
    var state = true

    let swipeLength: Double = Double(screenWidth) / 6

    let motionManager: CMMotionManager = CMMotionManager()
    let cas = CAShapeLayer()

    var gyroBool: Bool = true
    var motionAngle: Int = 0
    var isHorizontal: Bool = false
    var figRotationBool: Bool = true

    var motionState: Bool = false

    /// 現在の傾きを保存
    var storedRotationAngle: CGFloat = 0
    /// 前回動いた傾きを保存
    var lastRotationAngle: CGFloat = 0

    /// iPadが持ち上がっているかの基準
    var varZstate: Double = -0.98
    /// iPadが何度以上傾いたらviewを更新するか
    var varViewAngle: Int = 2
    /// Viewの回転アニメーションの時間
    var varViewDuration: Double = 0.3

    let moveInterval: Double = 0.01
    let movex = screenWidth / 4 / 2
    let movey = screenWidth / 4 / 2

    var rd: [Int] = []
    var lastSRtime: Date?
    var lastSRResp: Int = 0

    private func StartSetting() {
        if ExperimentViewController.storedParameter.isDemo { // TODO: isDemo
            view.viewWithTag(5000)!.layer.borderColor = UIColor.darkGray.cgColor
            view.viewWithTag(1)!.isHidden = false
            view.viewWithTag(2)!.isHidden = false
            view.viewWithTag(100)!.isHidden = false
            view.viewWithTag(900)!.isHidden = false
        } else {
            view.viewWithTag(1400)!.isHidden = true // EndSessionButton
            view.viewWithTag(4)!.isHidden = true // i button
            view.viewWithTag(11110)!.isHidden = true // dismissbutton
            view.viewWithTag(5000)!.layer.borderColor = UIColor.clear.cgColor
            view.viewWithTag(1)!.isHidden = true
            view.viewWithTag(2)!.isHidden = true
            view.viewWithTag(100)!.isHidden = true
            view.viewWithTag(900)!.isHidden = true
        }
        if gyroBool {
            if figRotationBool {
                gyroBool = false
                figRotationBool = false
                storedRotationAngle = 0
                lastRotationAngle = 0
                motionManager.accelerometerUpdateInterval = 0.05
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.underPointView.transform = CGAffineTransform.identity
                })
                (TRRect.viewWithTag(3) as! UIButton).setImage(UIImage(named: "02"), for: .normal)
            } else {
                figRotationBool = true
                motionManager.accelerometerUpdateInterval = 0.01
                (TRRect.viewWithTag(3) as! UIButton).setImage(UIImage(named: "16"), for: .normal)
            }
        } else {
            gyroBool = true
            (TRRect.viewWithTag(3) as! UIButton).setImage(UIImage(named: "17"), for: .normal)
        }
        if gyroBool {
            if figRotationBool {
                gyroBool = false
                figRotationBool = false
                storedRotationAngle = 0
                lastRotationAngle = 0
                motionManager.accelerometerUpdateInterval = 0.05
                // self.logRect.transform = CGAffineTransform.identity
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.underPointView.transform = CGAffineTransform.identity
                })
                (TRRect.viewWithTag(3) as! UIButton).setImage(UIImage(named: "02"), for: .normal)
            } else {
                figRotationBool = true
                motionManager.accelerometerUpdateInterval = 0.01
                (TRRect.viewWithTag(3) as! UIButton).setImage(UIImage(named: "16"), for: .normal)
            }
        } else {
            gyroBool = true
            (TRRect.viewWithTag(3) as! UIButton).setImage(UIImage(named: "17"), for: .normal)
        }
    }

    private func StartSession() {
        firstSwipeAngle = 9999

        BallStoreData.resetSwipeSessionData()
        allResp = 0
        lastSRResp = 0
        let labelPoint: UILabel = view.viewWithTag(100) as! UILabel
        labelPoint.text = "SR: " + BallStoreData.reinforcer.description + "\n" + "targetResp: " + BallStoreData.targetResp.description + "\n" + "allResp: " + allResp.description

        StoreData.startDate = Date()
        timerUseCase.start().subscribe().disposed(by: disposeBag)
        lastSRtime = StoreData.startDate
    }

    func EndSession() {
        currentPhaseDisposeBag = DisposeBag()
        let realTime = allRealTime.value
        let sessionTime = allSessionTime.value
        print("[EndSession] realTime: \(realTime), sessionTime: \(sessionTime)")
        StoreData.endDate = Date()
        StoreData.realTime = realTime
        StoreData.sessionTime = sessionTime

        EndAlert()
        isFinished = true
    }

    private func layoutRect() {
        let label1 = UILabel(frame: CGRect(x: 25, y: screenHeight * 3 / 20, width: screenWidth - 25, height: screenHeight / 10))
        label1.tag = 1
        label1.numberOfLines = 2
        label1.textColor = UIColor.lightGray
        view.addSubview(label1)
        let label2 = UILabel(frame: CGRect(x: 25, y: 60, width: screenWidth / 2, height: screenHeight / 10))
        label2.tag = 2
        label2.numberOfLines = 3
        label2.textColor = UIColor.lightGray
        label2.textAlignment = NSTextAlignment.left
        label2.text = "criterion: waiting first swipe\nvalue: ???????"
        logLabel = label2
        view.addSubview(label2)

        let labelPoint = UILabel(frame: CGRect(x: 0, y: 10, width: screenWidth, height: screenHeight / 8))
        labelPoint.tag = 100
        labelPoint.numberOfLines = 4
        labelPoint.textColor = UIColor.lightGray
        labelPoint.textAlignment = NSTextAlignment.center
        labelPoint.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2 / 2)
        labelPoint.text = "SR: " + BallStoreData.reinforcer.description + "\n" + "targetResp: " + BallStoreData.targetResp.description + "\n" + "allResp: " + allResp.description
        view.addSubview(labelPoint)

        let label = UILabel(frame: CGRect(x: 0, y: screenHeight / 10 * 9, width: screenWidth, height: screenHeight / 10))
        label.tag = 900
        label.numberOfLines = 3
        label.textColor = UIColor.lightGray
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2 / 3)
        label.text = ""
        view.addSubview(label)
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.05 // 0.05 //20Hz
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {
                cmAccelerometerData, _ in
                let acceleration: CMAcceleration = (cmAccelerometerData!.acceleration)
                let label = self.view.viewWithTag(900) as! UILabel
                label.text = "x: " + acceleration.x.description + "\n" + "y: " + acceleration.y.description + "\n" + "z: " + acceleration.z.description

                if ExperimentViewController.storedParameter.isUseSensor {
                    var radian: Double = atan2(Double(acceleration.y), Double(acceleration.x))
                    if radian < 0 {
                        radian = radian + 2 * Double.pi
                    }
                    var angle: Int = Int(360 - radian * 360 / (2 * Double.pi))
                    if angle == 360 {
                        angle = 0
                    }

                    self.isHorizontal = (acceleration.z <= self.varZstate)

                    if self.isHorizontal {
                        // ipadが水平の場合
                        self.motionAngle = 0
                        if !self.motionState {
                            self.storedRotationAngle = 0
                            self.lastRotationAngle = 0
                            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                                self.underPointView.transform = CGAffineTransform.identity
                            })
                        }
                        label.text = "Orientation initialized"
                    } else {
                        // ipadが水平でない場合
                        if angle < 90 {
                            self.motionAngle = angle + 270
                        } else {
                            self.motionAngle = angle - 90
                        }

                        if !self.motionState {
                            self.storedRotationAngle = CGFloat(self.motionAngle)
                            if Int(abs(self.lastRotationAngle - self.storedRotationAngle)) >= self.varViewAngle {
                                // ↓　0度から360度に移動したときの処理
                                if (self.lastRotationAngle <= 90 && self.storedRotationAngle >= 270) || (self.lastRotationAngle >= 270 && self.storedRotationAngle <= 90), self.motionManager.accelerometerUpdateInterval <= 0.5 {
                                    if self.lastRotationAngle <= 90, self.storedRotationAngle >= 270 {
                                        if Int(abs(self.lastRotationAngle - (360 - self.storedRotationAngle))) >= self.varViewAngle {
                                            self.ViewRotation()
                                        }
                                    } else {
                                        if Int(abs((360 - self.lastRotationAngle) - self.storedRotationAngle)) >= self.varViewAngle {
                                            self.ViewRotation()
                                        }
                                    }
                                } else {
                                    self.ViewRotation()
                                }
                            }
                        }

                        label.text = self.motionAngle.description
                    }
                } else {
                    label.text = "RotationState is false"
                    self.motionAngle = 0
                }
            })
        } else {
            label.text = "AccelerationSensor is unavairable"
        }

        view.viewWithTag(1)!.isHidden = true
        view.viewWithTag(2)!.isHidden = true
        view.viewWithTag(100)!.isHidden = true
        view.viewWithTag(900)!.isHidden = true
    }

    private func ViewRotation() {
        lastRotationAngle = storedRotationAngle
        UIView.animate(withDuration: varViewDuration, delay: 0, animations: { // ※ここのアニメ長さ調整
            if !self.motionState {
                self.underPointView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(self.motionAngle) / 180))
            }
        })
    }

    private func layoutCircleRect() {
        circleRect.isUserInteractionEnabled = false
        circleRect.backgroundColor = UIColor.white
        cas.path = CGPath(ellipseIn: circleRect.bounds, transform: nil)
        circleRect.layer.mask = cas

        view.addSubview(circleRect)
    }

    private func layoutSwipeRect() {
        swipeRect.isUserInteractionEnabled = true

        let button: UIButton = UIButton(frame: swipeRect.bounds)
        button.addTarget(self, action: #selector(setTUIS), for: .touchUpInside)
        swipeRect.addSubview(button)
        view.addSubview(swipeRect)
    }

    private func layoutStarRect() {
        starRect.isUserInteractionEnabled = true
        starRect.setImage(UIImage(named: "star1"), for: .normal)
        starRect.addTarget(self, action: #selector(setTstar), for: .touchDown)
        starRect.isHidden = true
        starAllRect.isHidden = true
        starAllRect.backgroundColor = UIColor(white: 0.0, alpha: 0.5)

        view.addSubview(starAllRect)
        view.addSubview(starRect)
    }

    @IBAction private func setTstar(_ sender: UIButton) {
        if rftOnBool {
            rftOnBool = false
            let time: Date = Date()
            let reinforcementOffTime = allRealTime.value
            StoreData.listData += BallStoreData.reinforcerOffID + ": \(reinforcementOffTime)\n"
            self.reinforcementOffTime.accept(reinforcementOffTime)
            DispatchQueue.main.async {
                print("touched")
                self.starRect.isHidden = true
                self.starAllRect.isHidden = true
                (self.view.viewWithTag(5000) as! SCNView).isUserInteractionEnabled = true
                self.lastSRtime = time
            }
            ExperimentViewController.storedValue.getCurrentPhases().reinforcers += 1
            decisionGoNextPhase()
        }
    }

    func SRstarAnim() {
        DispatchQueue.main.async {
            self.starRect.center = CGPoint(x: screenWidth / 2, y: screenHeight / 10)
            self.starRect.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(self.motionAngle) / 180))
            self.starAllRect.isHidden = false
            self.starRect.isHidden = false
            self.starRect.alpha = 1.0

            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.starRect.center = CGPoint(x: self.starRect.center.x, y: self.starRect.center.y - 20)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    self.starRect.center = CGPoint(x: self.starRect.center.x, y: self.starRect.center.y + 20)
                }, completion: { _ in
                })
            })
        }
    }

    @IBAction private func setTUIS(_ sender: UIButton) {
        let label: UILabel = view.viewWithTag(1) as! UILabel
        label.text = ""
    }

    @IBAction private func setTUIT(_ sender: UIButton) {
        switch sender.tag {
        case 11110:
            currentPhaseDisposeBag = DisposeBag()
            let viewController = ViewController()
            viewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            timerUseCase.finish().subscribe().disposed(by: disposeBag)
            present(viewController, animated: true, completion: nil)
        case 4:
            if view.viewWithTag(900)!.isHidden {
                view.viewWithTag(5000)!.layer.borderColor = UIColor.darkGray.cgColor
                view.viewWithTag(1)!.isHidden = false
                view.viewWithTag(2)!.isHidden = false
                view.viewWithTag(100)!.isHidden = false
                view.viewWithTag(900)!.isHidden = false
            } else {
                view.viewWithTag(5000)!.layer.borderColor = UIColor.clear.cgColor
                view.viewWithTag(1)!.isHidden = true
                view.viewWithTag(2)!.isHidden = true
                view.viewWithTag(100)!.isHidden = true
                view.viewWithTag(900)!.isHidden = true
            }
        case 3:
            if gyroBool {
                if figRotationBool {
                    gyroBool = false
                    figRotationBool = false
                    storedRotationAngle = 0
                    lastRotationAngle = 0
                    motionManager.accelerometerUpdateInterval = 0.05
                    // self.logRect.transform = CGAffineTransform.identity
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                        self.underPointView.transform = CGAffineTransform.identity
                    })
                    (TRRect.viewWithTag(3) as! UIButton).setImage(UIImage(named: "02"), for: .normal)
                } else {
                    figRotationBool = true
                    motionManager.accelerometerUpdateInterval = 0.01
                    (TRRect.viewWithTag(3) as! UIButton).setImage(UIImage(named: "16"), for: .normal)
                }
            } else {
                gyroBool = true
                (TRRect.viewWithTag(3) as! UIButton).setImage(UIImage(named: "17"), for: .normal)
            }
        case 1:
            if view.backgroundColor != UIColor.black {
                view.backgroundColor = UIColor.black
            } else {
                view.backgroundColor = UIColor.white
            }
        default:
            break
        }
    }

    @IBAction private func setTUIB(_ sender: UIButton) {
        switch sender.tag {
        case 1400:
            EndSession()
        default:
            break
        }
    }

    private func NumPeriodCheck(str: String) -> Bool {
        var once: Bool = false
        for i in str {
            switch i {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                break
            case ".":
                if once { // 2度目以降の"."を許さない
                    return false
                }
                once = true
            default:
                return false
            }
        }
        return true
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

    private func NumMinusPeriodCheck(str: String) -> Bool {
        var once: Bool = false
        var i = 0
        for x in str {
            if i == 0 {
                switch x {
                case "-":
                    break
                case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                    break
                default:
                    return false
                }
            } else {
                switch x {
                case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                    break
                case ".":
                    if once { // 2度目以降の"."を許さない
                        return false
                    }
                    once = true
                default:
                    return false
                }
            }
            i += 1
        }
        return true
    }

    private func layoutBackRect() {
        backRect.isUserInteractionEnabled = true
        backRect.backgroundColor = UIColor.clear
        backRect.frame = CGRect(x: 10, y: 10, width: 50, height: 50)

        let button = UIButton(frame: backRect.bounds)
        button.tag = 11110
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(setTUIT), for: .touchUpInside)
        backRect.addSubview(button)

        view.addSubview(backRect)
    }

    private func layoutTRRect() {
        TRRect.isUserInteractionEnabled = true
        TRRect.backgroundColor = UIColor.clear
        TRRect.frame = CGRect(x: screenWidth - 60 - 60 - 60 - 60 - 60, y: 10, width: 50 + 60 + 60 + 60 + 60, height: 50)

        let button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button1.setImage(UIImage(named: "02"), for: .normal)
        button1.tag = 1
        button1.addTarget(self, action: #selector(setTUIT), for: .touchUpInside)
        TRRect.addSubview(button1)
        let scl: CGFloat = 5
        let button11 = UIButton(frame: CGRect(x: scl, y: scl, width: 50 - scl * 2, height: 50 - scl * 2))
        button11.isUserInteractionEnabled = false
        button11.setImage(UIImage(named: "blackcircle"), for: .normal)
        TRRect.addSubview(button11)
        let button2 = UIButton(frame: CGRect(x: 60, y: 0, width: 50, height: 50)) // ピザの枠
        button2.tag = 2
        button2.setImage(UIImage(named: "02"), for: .normal)
        button2.addTarget(self, action: #selector(setTUIT), for: .touchUpInside)
        TRRect.addSubview(button2)
        let button21 = UIButton(frame: CGRect(x: 60 + scl, y: scl, width: 50 - scl * 2, height: 50 - scl * 2))
        button21.isUserInteractionEnabled = false
        button21.setImage(UIImage(named: "pizza_pd"), for: .normal)
        TRRect.addSubview(button21)
        let button3 = UIButton(frame: CGRect(x: 60 + 60, y: 0, width: 50, height: 50))
        button3.tag = 3
        button3.setImage(UIImage(named: "02"), for: .normal)
        button3.addTarget(self, action: #selector(setTUIT), for: .touchUpInside)
        TRRect.addSubview(button3)
        let button4 = UIButton(frame: CGRect(x: 60 + 60 + 60, y: 0, width: 50, height: 50))
        button4.tag = 4
        button4.setImage(UIImage(named: "info"), for: .normal)
        button4.addTarget(self, action: #selector(setTUIT), for: .touchUpInside)
        TRRect.addSubview(button4)
        let button5 = UIButton(frame: CGRect(x: 60 + 60 + 60 + 60, y: 0, width: 50, height: 50))
        button5.tag = 5
        button5.setImage(UIImage(named: "settings"), for: .normal)
        button5.addTarget(self, action: #selector(setTUIT), for: .touchUpInside)
        TRRect.addSubview(button5)

        view.addSubview(TRRect)
        button1.isHidden = true
        button11.isHidden = true
        button2.isHidden = true
        button21.isHidden = true
        button3.isHidden = true
        button5.isHidden = true
    }

    private func layoutBRRect() {
        BRRect.isUserInteractionEnabled = true
        BRRect.backgroundColor = UIColor.clear
        BRRect.frame = CGRect(x: screenWidth - 60, y: screenHeight - 10 - 50, width: 50, height: 50)

        let button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) // ピザの枠
        button1.setImage(UIImage(named: "save"), for: .normal)
        button1.tag = 1400
        button1.addTarget(self, action: #selector(setTUIB), for: .touchUpInside)
        BRRect.addSubview(button1)

        view.addSubview(BRRect)
    }

    private func layoutLogRect() {
        logRect.isUserInteractionEnabled = false
        logRect.backgroundColor = UIColor.clear // brown
        logRect.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        logRect.image = UIImage(named: "circle01")
        view.addSubview(logRect)

        logSwipeView.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        logSwipeView.backgroundColor = UIColor.clear
        logSwipeView.layer.cornerRadius = logRect.bounds.width / 2
        // 範囲外を描画しない
        logSwipeView.clipsToBounds = true
        logSwipeView.isUserInteractionEnabled = true
        logSwipeView.tag = 1000

        view.addSubview(logSwipeView)
    }

    private func layoutUPRect() {
        underPointView.transform = CGAffineTransform.identity
        underPointView.frame = CGRect(x: 0, y: 0, width: screenWidth / 10, height: screenWidth / 10)
        underPointView.center = CGPoint(x: screenWidth / 2, y: screenHeight - underPointView.bounds.height)
        underPointView.backgroundColor = UIColor.clear
        underPointView.layer.cornerRadius = underPointView.bounds.width / 2
        // 範囲外を描画しない
        underPointView.clipsToBounds = true
        underPointView.image = UIImage(named: "underpoint")
        underPointView.isUserInteractionEnabled = true

        underPointView.isHidden = !ExperimentViewController.storedParameter.isDemo

        view.addSubview(underPointView)
    }

    @objc private func LogRectMove(_ timer: Timer) {
        Move()
    }

    func Move() {
        let x = arc4random_uniform(4)
        switch x {
        case 11110:
            if logRect.center.x - logRect.bounds.width / 2 - movex - logRect.bounds.width / 2 < 0 {
                Move()
            } else {
                logRect.center.x -= movex
                logSwipeView.center.x = logRect.center.x
            }
        case 1:
            if logRect.center.x + logRect.bounds.width / 2 + movex + logRect.bounds.width / 2 > screenWidth {
                Move()
            } else {
                logRect.center.x += movex
                logSwipeView.center.x = logRect.center.x
            }
        case 2:
            // ボタンに重ならないように
            if logRect.center.y - logRect.bounds.height / 2 - movey - 50 < 0 {
                Move()
            } else {
                logRect.center.y -= movey
                logSwipeView.center.y = logRect.center.y
            }
        case 3:
            // ボタンに重ならないように
            if logRect.center.y + logRect.bounds.height / 2 + movey + 50 > screenHeight {
                Move()
            } else {
                logRect.center.y += movey
                logSwipeView.center.y = logRect.center.y
            }
        default:
            break
        }
    }

    func srRespFeedback() {
        if BallStoreData.reinforcer >= StoreData.maxReinforcers {
            view.isUserInteractionEnabled = false
        }
        motionState = true
        view.isUserInteractionEnabled = false

        // 0.6
        let dur: Double = StoreData.rftDuration / 2
        UIView.animate(withDuration: dur, delay: 0, options: .curveEaseIn, animations: {
            self.logRect.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(self.lastRotationAngle + 178) / 180))
        })
        UIView.animate(withDuration: dur / 10, delay: dur - dur / 10 / 4, animations: {
            self.logRect.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(self.lastRotationAngle + 182) / 180))
        })
        UIView.animate(withDuration: dur - dur / 10 / 4, delay: dur + dur / 10 / 4, options: .curveEaseOut, animations: {
            self.logRect.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(self.lastRotationAngle) / 180))
        }, completion: { _ in
            self.motionState = false
            if BallStoreData.reinforcer >= StoreData.maxReinforcers {
                self.EndSession()
            } else {
                self.lastSRtime = Date()
                self.view.isUserInteractionEnabled = true
            }
        })
    }

    func targetRespFeedback() {
        motionState = true
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.logRect.center = CGPoint(x: self.logRect.center.x, y: self.logRect.center.y - 20)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.logRect.center = CGPoint(x: self.logRect.center.x, y: self.logRect.center.y + 20)
            }, completion: { _ in
                self.motionState = false
            })
        })
    }

    func allRespFeedback() {
        motionState = true

        let duration: Double = 0.02
        let angle: CGFloat = CGFloat(Double.pi / 36 / 2)

        UIView.animate(withDuration: duration, animations: {
            self.logRect.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(self.lastRotationAngle) / 180) + angle)
        }, completion: { _ in
            UIView.animate(withDuration: duration * 2, animations: {
                self.logRect.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(self.lastRotationAngle) / 180) - angle)
            }, completion: { _ in
                UIView.animate(withDuration: duration * 2, animations: {
                    self.logRect.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(self.lastRotationAngle) / 180) + angle)
                }, completion: { _ in
                    UIView.animate(withDuration: duration, animations: {
                        self.logRect.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(self.lastRotationAngle) / 180))
                    }, completion: { _ in
                        self.motionState = false
                    })
                })
            })
        })
    }

    func decisionSchedFR(resp: Int) -> Bool {
        if resp % BallStoreData.value == 0 {
            StoreData.listData += BallStoreData.reinforcerOnID + ": " + "\(allRealTime.value)" + "\n"
            BallStoreData.reinforcer += 1
            return true
        } else {
            return false
        }
    }

    func decisionSchedVI() -> Bool {
        let x: Double = Double(rd[BallStoreData.reinforcer])
        if Double(Date().timeIntervalSince(lastSRtime!)) >= x / 1000 {
            lastSRtime = Date()
            StoreData.listData += BallStoreData.reinforcerOnID + ": " + "\(allRealTime.value)" + "\n"
            BallStoreData.reinforcer += 1
            return true
        } else {
            return false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}

extension ExperimentViewController {
    func nextTimer(_ phaseParameter: StoredParameterable) {
        print("[ExperimentViewController]nextTimer() called: \(allRealTime.value)")
        let currentPhaseParameter = phaseParameter.getCurrentPhases(ExperimentViewController.storedValue.currentPhaseNum)
        if currentPhaseParameter.endType == .Time {
            if phaseParameter.getCurrentPhases(ExperimentViewController.storedValue.currentPhaseNum).endParameter > 0 {
                let phaseEndSessionTimeMilliseconds: Int = phaseParameter.getCurrentPhases(ExperimentViewController.storedValue.currentPhaseNum).endParameter * 60 * 1000
                currentPhaseDisposeBag = DisposeBag()
                print("nextTimer: \(currentPhaseSessionTime.value)")

                currentPhaseSessionTime
                    // 値変更の非同期反映待ち5秒。セッション時間は1分単位のため影響しない。
                    .skipUntil(Observable.just(()).delay(5, scheduler: ConcurrentDispatchQueueScheduler(queue: .global())))
                    .filter { phaseEndSessionTimeMilliseconds <= $0 }
                    .take(1)
                    .filter { _ in !self.isFinished }
                    .debug()
                    .subscribe(onNext: { [weak self] _ in
                        self?.goNextPhase()
                    })
                    .disposed(by: currentPhaseDisposeBag)

                currentPhaseSessionTime
                    // 値変更の非同期反映待ち5秒。セッション時間は1分単位のため影響しない。
                    .skipUntil(Observable.just(()).delay(5, scheduler: ConcurrentDispatchQueueScheduler(queue: .global())))
                    .filter { _ in self.isFinished }
                    .take(1)
                    .subscribe(onNext: { [weak self] _ in
                        print("このセッションは既に破棄されました。")
                        self?.currentPhaseDisposeBag = DisposeBag()
                    })
                    .disposed(by: currentPhaseDisposeBag)
            }
        }
    }

    func goNextPhase() {
        print("goNextPhase() - \(phaseValueWhenPreviousPhase)")
        print("[ExperimentViewController]goNextPhase() called: \(allRealTime.value)")
        StoreData.listData += BallStoreDataX.nextPhaseID + ": " + "\(allRealTime.value)" + "\n"
        if ExperimentViewController.storedValue.currentPhaseNum >= ExperimentViewController.storedParameter.phases.count {
            print("終了")
            EndSession()
        } else {
            PreviousSessionValue: do {
                currentPhaseDisposeBag = DisposeBag()
                phaseValueWhenPreviousPhase = (allRealTime.value, allSessionTime.value)
            }
            ExperimentViewController.storedValue.nextPhase(ExperimentViewController.storedParameter)
            nextTimer(ExperimentViewController.storedParameter)
            renewalLabel()
        }
    }

    func renewalLabel() {
        if ExperimentViewController.storedParameter.isDemo {
            let storedVal = ExperimentViewController.storedValue
            let currentPhaseValue = storedVal.getCurrentPhases()
            let currentPhaseParameter = ExperimentViewController.storedParameter.getCurrentPhases(storedVal.currentPhaseNum)
            var valueStr: String = ""
            var reinforcerStr: String = ""
            var endTypeStr: String = ""
            switch currentPhaseParameter.schedule {
            case .EXT:
                valueStr = "schedule: EXT"
            case .FR:
                valueStr = "Phase \(storedVal.currentPhaseNum): FR \(currentPhaseParameter.schedParameter)"
                reinforcerStr = "(SR: \(currentPhaseValue.reinforcers))"
            }
            endTypeStr = "EndPhase: \(currentPhaseParameter.endType) \(currentPhaseParameter.endParameter)"

            func fix360(_ angle: Int) -> Int {
                var result = angle
                while !(result >= 0 && result < 360) {
                    if result < 0 {
                        result += 360
                    } else if result >= 360 {
                        result -= 360
                    }
                }
                return result
            }
            let criterionStr: String = currentPhaseParameter.schedule == .EXT ? "criterion: none\n" : currentPhaseValue.targetAngle == 999 ? "criterion: First response\n" : "criterion: \(fix360(currentPhaseValue.targetAngle - currentPhaseParameter.toleranceAngle)) <= x <= \(fix360(currentPhaseValue.targetAngle + currentPhaseParameter.toleranceAngle))\n"

            DispatchQueue.main.async {
                self.logLabel?.text = criterionStr + valueStr + reinforcerStr + "\n" + endTypeStr
                self.logLabel?.setNeedsDisplay()
            }
            print(criterionStr + valueStr + reinforcerStr + "\n" + endTypeStr)
        }
    }

    func decisionGoNextPhase() {
        print("decisionGoNextPhase() called")
        let storedVal = ExperimentViewController.storedValue
        func decision() -> Bool {
            let currentPhaseValue = storedVal.getCurrentPhases()
            let currentPhaseParameter = ExperimentViewController.storedParameter.getCurrentPhases(storedVal.currentPhaseNum)
            switch currentPhaseParameter.endType {
            case .SR:
                return currentPhaseValue.reinforcers >= currentPhaseParameter.endParameter
            case .Swipe:
                print("currentPhaseValue.controlResp: \(currentPhaseValue.controlResp)")
                print("currentPhaseValue.targetResp: \(currentPhaseValue.targetResp)")
                print("currentPhaseParameter.endParameter: \(currentPhaseParameter.endParameter)")
                return currentPhaseValue.controlResp + currentPhaseValue.targetResp >= currentPhaseParameter.endParameter
            case .Time:
                break
            }
            return false
        }
        if decision() {
            goNextPhase()
        }
    }
}

extension ExperimentViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("self.view.subviews.count: \(view.subviews.count)")
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        print("self.view.subviews.count: \(view.subviews.count)")

        cleanVariables()

        view = nil
    }

    func cleanVariables() {
        isFinished = true
        scnView = nil
        scnScene = nil
    }
}
