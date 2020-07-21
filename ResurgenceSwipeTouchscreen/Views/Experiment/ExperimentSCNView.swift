//
//  ExperimentSCNView.swift
//
//  Created by YutoMizutani on 2017/07/21.
//  Copyright © 2017 Yuto Mizutani. All rights reserved.
//

import CoreMotion
import QuartzCore
import SceneKit
import UIKit

import OperantKit
import RxCocoa
import RxSwift

class ExperimentSCNView: SCNView {
    var isTransforming: Bool = true
    var movingCount: Int = 0

    weak var experimentViewController: ExperimentViewController!

    init(_ experimentViewController: ExperimentViewController) {
        print("ExperimentViewController")
        self.experimentViewController = experimentViewController
        super.init(frame: experimentViewController.view.frame, options: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate var prevLocation: CGPoint!
    fileprivate var nowLocation: CGPoint!
    fileprivate var state = true
    private let swipeLength: Double = Double(screenWidth) / 6

    fileprivate var isCriterion: Bool = false

    private var SingleTouch: Bool = true

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("cancel")
    }

    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        print("touchesEstimatedPropertiesUpdated")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fixedCam: do {
            transform = CGAffineTransform.identity

            // タップ時にボールが消えるようになる
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 0
//            let newCameraNode = SCNNode()
//            newCameraNode.position = SCNVector3(x: 0, y: 0, z: 2.5)
//            newCameraNode.rotateUp(by: 90 + (-20*(.pi / 180)))
//            self.pointOfView = newCameraNode
//            SCNTransaction.commit()
        }

        // allowsCameraControl = false
        isCriterion = false
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.isUserInteractionEnabled = true
        }
        if !SingleTouch {
            allowsCameraControl = false
        }
        SingleTouch = false

        if touches.count >= 2 {
            allowsCameraControl = false
        } else {
            let touch: UITouch = touches.first!
            prevLocation = touch.location(in: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count >= 2 {
            // 2本以上の指で触れていた場合，アニメーションを停止する。

            allowsCameraControl = false
        } else {
            // 1本指でのスワイプ移動時

            let touch: UITouch = touches.first!
            nowLocation = touch.location(in: self)

            if state {
                let current_swipeLength: Double = sqrt(pow(Double(nowLocation.x - prevLocation.x), 2) + pow(Double(nowLocation.y - prevLocation.y), 2))

                if allowsCameraControl {
                    let criterion: Double = current_swipeLength - swipeLength
                    if criterion >= 0 {
                        isUserInteractionEnabled = false
                        enabledResponse()
                    }
                }
            }
        }
    }

    func colorchange(color: UIColor) {
        DispatchQueue.main.async {
            self.superview!.backgroundColor = color
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isUserInteractionEnabled = true
        isTransforming = true
        DispatchQueue.global().async {
            if !self.isCriterion {
                BallStoreData.shortResp += 1
                ExperimentViewController.storedValue.getCurrentPhases().unregisterdResp += 1

                StoreData.listData += BallStoreData.shortRespID + ": \(self.experimentViewController!.allRealTime.value)\n"
            } else {
                self.experimentViewController.decisionGoNextPhase()
            }

            let touch: UITouch = touches.first!
            self.nowLocation = touch.location(in: self)
            let length: Double = sqrt(pow(Double(self.nowLocation.x - self.prevLocation.x), 2) + pow(Double(self.nowLocation.y - self.prevLocation.y), 2))
            // print(length)
            let p_length: Double = Double(Int(length * 1000)) / 1000
            StoreData.listData += BallStoreData.lengthID + ": " + p_length.description + "\n" // "\(ExperimentViewController.allRealTime.value)" + "\n" //": "
            self.experimentViewController.renewalLabel()
        }

        allowsCameraControl = true
        if !state {
            state = true
        }

        let now = Date()
        DispatchQueue.global().async {
            while !self.SingleTouch {
                if Date().timeIntervalSince(now) >= 0.1 {
                    DispatchQueue.main.async {
                        self.SingleTouch = true
                    }
                    break
                }
            }
        }
    }
}

extension ExperimentSCNView {
    func enabledResponse() {
        let label: UILabel = superview!.viewWithTag(1) as! UILabel
        let labelPoint: UILabel = superview!.viewWithTag(100) as! UILabel
        let currentPhaseValue = ExperimentViewController.storedValue.getCurrentPhases()
        let currentPhaseParameter = ExperimentViewController.storedParameter.getCurrentPhases(ExperimentViewController.storedValue.currentPhaseNum)

        isCriterion = true
        state = false
        DispatchQueue.global().async {
            var radian: Double = atan2(Double(self.nowLocation.y - self.prevLocation.y), Double(self.nowLocation.x - self.prevLocation.x))
            if radian < 0 {
                radian = radian + 2 * Double.pi
            }
            var angle: Int = Int(360 - radian * 360 / (2 * Double.pi))
            if angle == 360 {
                angle = 0
            }
            if ExperimentViewController.storedParameter.isUseSensor { // 傾きをONにしていた場合
                angle += self.experimentViewController.motionAngle
            }
            while angle >= 360 {
                angle -= 360
            }

            fixCam: do {
                var transformAngle = CGFloat(360 - angle - 90) * (CGFloat.pi / 180)
                // 傾きをONにしていた場合
                if ExperimentViewController.storedParameter.isUseSensor {
                    print("self.experimentViewController.motionAngle ?? 0: \(self.experimentViewController.motionAngle)")
                    transformAngle -= CGFloat(360 - self.experimentViewController.motionAngle) * (CGFloat.pi / 180)
                }
                print("angleangleangleangle: \(angle)")
                DispatchQueue.main.async {
                    self.transform = CGAffineTransform(rotationAngle: transformAngle)
                }
            }

            BallStoreData.swipeAngle[angle] += 1
            currentPhaseValue.allAngles[angle] += 1
            currentPhaseValue.respAngles.append(angle)

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

            func decisionAngle(_ angle: Int) -> Bool {
                if currentPhaseValue.targetAngle == 1000 {
                    print("[ExperimentSCNView] decisionAngle() currentPhaseParameter.targetAngle == 1000 -> no set targetAngle")
                    return false
                }
                if currentPhaseValue.targetAngle == 999 {
                    print("[ExperimentSCNView] decisionAngle() currentPhaseParameter.targetAngle == 999 -> first alternative SR")
                    let target = angle - 180 > 0 ? angle - 180 : angle - 180 + 360
                    ExperimentViewController.storedValue.getCurrentPhases().targetAngle = target
                    ExperimentViewController.storedParameter.getCurrentPhases(ExperimentViewController.storedValue.currentPhaseNum).userAngle = target
                    return false
                }

                let angleM: (min: Int, max: Int) = (min: fix360(currentPhaseValue.targetAngle - currentPhaseParameter.toleranceAngle), max: currentPhaseValue.targetAngle + currentPhaseParameter.toleranceAngle)
                print("[ExperimentSCNView] decisionAngle() currentPhaseParameter.targetAngle \(currentPhaseValue.targetAngle)")
                if angleM.min > angleM.max { // e.g.:315 to 45
                    if angle >= angleM.min, angle <= 360 {
                        return true
                    } else if angle >= 0, angle <= angleM.max {
                        return true
                    }
                } else {
                    if angleM.min <= angle, angle <= angleM.max {
                        return true
                    }
                }
                return false
            }

            func getRotation() -> String {
                return "\(ExperimentViewController.storedParameter.isUseSensor ? ", Rotation: " + (self.experimentViewController.motionAngle == 0 ? "Horizontal" : "\(self.experimentViewController!.motionAngle)") : "")"
            }

            if decisionAngle(angle) {
                StoreData.listData += BallStoreData.targetRespID + ": \(self.experimentViewController.allRealTime.value), Angle: \(angle.description)\(getRotation())\n"
                BallStoreData.targetResp += 1
                self.experimentViewController.allResp += 1

                currentPhaseValue.targetResp += 1
                self.renewalLabel()
                DispatchQueue.main.async {
                    label.text = angle.description + "\n" + "correct "
                }

                func scheduleEXT() {}
                func scheduleFR() {
                    func desicionFR() -> Bool {
                        print("scheduleFR() called")
                        print("currentPhaseValue.targetResp: \(currentPhaseValue.targetResp)")
                        print("currentPhaseValue.lastSRresp: \(currentPhaseValue.lastSRresp)")
                        print("currentPhaseParameter.schedParameter: \(currentPhaseParameter.schedParameter)")
                        if currentPhaseValue.targetResp - currentPhaseValue.lastSRresp >= currentPhaseParameter.schedParameter {
                            currentPhaseValue.lastSRresp = currentPhaseValue.targetResp
                            return true
                        } else {
                            return false
                        }
                    }

                    if desicionFR() {
                        reinforcement()
                    }
                }

                func reinforcement() {
                    let reinforcementOnTime = self.experimentViewController.allRealTime.value
                    StoreData.listData += BallStoreData.reinforcerOnID + ": \(reinforcementOnTime)\n"
                    self.experimentViewController.reinforcementOnTime.accept(reinforcementOnTime)
                    BallStoreData.reinforcer += 1

                    self.experimentViewController.lastSRResp = BallStoreData.targetResp
                    self.experimentViewController.rftOnBool = true
                    self.renewalLabel()
                    DispatchQueue.main.async {
                        self.experimentViewController.SRstarAnim()
                    }
                }

                switch currentPhaseParameter.schedule {
                case .EXT:
                    break
                case .FR:
                    scheduleFR()
                }
            } else {
                StoreData.listData += BallStoreData.controlRespID + ": \(self.experimentViewController.allRealTime.value), Angle: \(angle.description)\(getRotation())\n"
                BallStoreData.controlResp += 1

                currentPhaseValue.controlResp += 1

                self.experimentViewController.allResp += 1
                self.renewalLabel()
                DispatchQueue.main.async {
                    label.text = angle.description + "\n" + "incorrect"
                }
            }
        }
    }

    func renewalLabel() {
        DispatchQueue.main.async {
            if let labelPoint: UILabel = self.superview!.viewWithTag(100) as? UILabel {
                let text = "SR: \(BallStoreData.reinforcer)\ntargetResp: \(BallStoreData.targetResp)\nallResp: \(self.experimentViewController.allResp)"
                labelPoint.text = text
            }
        }
    }
}
