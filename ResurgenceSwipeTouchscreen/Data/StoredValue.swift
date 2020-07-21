//
//  StoredValue.swift
//
//  Created by YutoMizutani on 2017/07/24.
//  Copyright © 2017 Yuto Mizutani. All rights reserved.
//

import Foundation

protocol StoredValuable {
    var currentPhaseNum: Int { get }
    var phases: [PhaseValue] { get }
    func addPhase(targetAngle: Int)
    func getCurrentPhases() -> PhaseValue
    func nextPhase(_ phaseParameter: StoredParameterable)
}

class StoredValue: StoredValuable {
    private(set) var currentPhaseNum: Int = 1
    var phases: [PhaseValue] = []

    init(firstTargetAngle: Int = 0, isEXT: Bool = false) {
        if isEXT {
            addPhase(targetAngle: 1000)
        } else {
            addPhase(targetAngle: firstTargetAngle)
        }
    }

    func addPhase(targetAngle: Int) {
        phases.append(PhaseValue(targetAngle: targetAngle))
    }

    func getCurrentPhases() -> PhaseValue {
        return phases[currentPhaseNum - 1]
    }

    func nextPhase(_ phaseParameter: StoredParameterable) {
        addPhase(targetAngle: computeNextTargetAngle(phaseParameter))
        currentPhaseNum += 1
    }
}

extension StoredValue {
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
}

extension StoredValue {
    fileprivate func computeNextTargetAngle(_ phaseParameter: StoredParameterable) -> Int {
        print("CurrentPhase: \(currentPhaseNum)")
        if phaseParameter.getCurrentPhases(currentPhaseNum + 1).schedule == .EXT {
            return 1000
        }
        if phaseParameter.angleAlgorithm == .angle {
            return phaseParameter.getCurrentPhases(currentPhaseNum + 1).userAngle! // FIXME: nil時にエラー
        }

        var resultAngle: Int = 0
        let value = getCurrentPhases()
        // var anglePerX:[Int] = []

        var repeatCount: Int = 0
        var tmpTryCount: Int = 0
        repeat {
            if !value.respAngles.isEmpty {
                tmpTryCount += 1
                // 分ける
                // let separate10Degree = true
                var anglePer10 = [[Int]].init(repeating: [0, 0], count: 36)
                for i in 0 ..< anglePer10.count {
                    // 配列1番目に角度を格納 -> ソート前に追加して角度を保存
                    anglePer10[i][1] = i * 10
                }
                for angle in value.respAngles {
                    // データを10度ずつ回数カウント
                    anglePer10[angle / 10][0] += 1
                }

                switch phaseParameter.angleAlgorithm {
                case .plus180:
                    // カウント順にソート
                    anglePer10.sort { $1[0] < $0[0] }

                    // MARK: 最も多い角度の反対の角度を ... これ被験者にバレる？

                    resultAngle = fix360(anglePer10[tmpTryCount - 1][1] + 180)
                    print(" // MARK: 最も多い角度の反対の角度を ... これ被験者にバレる？: \(tmpTryCount)////\(resultAngle)")
                case .plus180andLeast:
                    // カウント順にソート
                    anglePer10.sort { $1[0] < $0[0] }
                    // 180度plus
                    resultAngle = fix360(anglePer10[0][1] + 180)
                    // 180 plusした値が次に大きい数であった場合
                    if fix360(resultAngle) == fix360(anglePer10[1][1]) {
                        // ランダム逆順に選択
                        anglePer10.sort { $1[0] > $0[0] }
                        print("\(anglePer10)")
                        var array: [Int] = []
                        if anglePer10.count > 1 {
                            var i = 0
                            while anglePer10.count > i, anglePer10[0][0] == anglePer10[i][0] {
                                print("adperand")
                                array.append(anglePer10[i][1])
                                i += 1
                            }
                            repeat {
                                resultAngle = fix360(array[Int(arc4random_uniform(UInt32(array.count)))])
                            } while !decisionChrisOrder(resultAngle, phaseParameter: phaseParameter, repeatCount: repeatCount)
                        } else {
                            resultAngle = fix360(anglePer10[tmpTryCount - 1][1])
                        }
                    }
                case .least:
                    // カウント逆順にソート
                    anglePer10.sort { $1[0] > $0[0] }
                    print("\(anglePer10)")
                    var array: [Int] = []
                    if anglePer10.count > 1 {
                        var i = 0
                        while anglePer10.count > i, anglePer10[0][0] == anglePer10[i][0] {
                            print("adperand")
                            array.append(anglePer10[i][1])
                            i += 1
                        }
                        // 最小の角度の中からランダムに選択
                        resultAngle = fix360(array[Int(arc4random_uniform(UInt32(array.count)))])
                    } else {
                        resultAngle = fix360(anglePer10[tmpTryCount - 1][1])
                    }

                case .angle:
                    break
                case .theLeast180OrAnotherRandom: // YM add 2018/01/15，360/currentPhaseAngleRangeに余りのない数が必要。
                    // 角度の範囲毎に再計算

                    // 現在の角度の範囲を取得。
                    // ＋ー範囲+その角度 が範囲。
                    let currentPhaseAngleRange = phaseParameter.getCurrentPhases(currentPhaseNum).toleranceAngle * 2 + 1
                    // 基準角を取得。これがないと重なる可能性がある。
                    let currentPhaseAngle = phaseParameter.getCurrentPhases(currentPhaseNum).userAngle! % currentPhaseAngleRange

                    /// 現在の角度の範囲から次の角度を決める。
                    var anglePerUserAngle = [[Int]].init(repeating: [0, 0], count: 360 / currentPhaseAngleRange)
                    for i in 0 ..< anglePerUserAngle.count {
                        // 配列1番目に角度を格納 -> ソート前に追加して角度を保存
                        anglePerUserAngle[i][1] = i * currentPhaseAngleRange
                    }
                    for angle in value.respAngles {
                        // データをUser度ずつ回数カウント
                        anglePerUserAngle[fix360(angle - currentPhaseAngle) / currentPhaseAngleRange][0] += 1
                    }

                    // +180度の配列番目は
                    let angle180 = fix360(phaseParameter.getCurrentPhases(currentPhaseNum).userAngle! - currentPhaseAngle + 180)
                    let angle180ArrayNum = angle180 / currentPhaseAngleRange

                    // カウント逆順にソート
                    anglePerUserAngle.sort { $1[0] > $0[0] }
                    print("anglePerUserAngle: \(anglePerUserAngle)")
                    var array: [Int] = []
                    if anglePerUserAngle.count > 1 {
                        var i = 0
                        while anglePerUserAngle.count > i, anglePerUserAngle[0][0] == anglePerUserAngle[i][0] {
                            print("adperand")
                            array.append(anglePerUserAngle[i][1])
                            i += 1
                        }
                        // 最小の角度の中からランダムに選択
                        var isFound = false
                        for c in array {
                            // もし最小角に+180が含まれていれば
                            if c == anglePerUserAngle[angle180ArrayNum][1] {
                                isFound = true
                                print("+180====================================================================================================================================")
                                resultAngle = fix360(anglePerUserAngle[angle180ArrayNum][1] + currentPhaseAngle)
                                break
                            }
                        }
                        // そうでなければ 全体から random。しかし anglePerUserAngle[angle180ArrayNum][1]とtarget以外とする。
                        if !isFound {
                            repeat {
                                resultAngle = fix360(anglePerUserAngle[Int(arc4random_uniform(UInt32(anglePerUserAngle.count)))][1] + currentPhaseAngle)
                                print("random180====================================================================================================================================")
                            } while resultAngle == fix360(anglePerUserAngle[angle180ArrayNum][1]) || resultAngle == fix360(phaseParameter.getCurrentPhases(currentPhaseNum).userAngle!)
                        }
                    } else {
                        // +180度は
                        let angle180 = fix360(phaseParameter.getCurrentPhases(currentPhaseNum).userAngle! + 180)
                        resultAngle = angle180
                    }
                case .random: // YM add 2018/01/15，360/currentPhaseAngleRangeに余りのない数が必要。
                    // 現在の角度の範囲を取得。
                    // ＋ー範囲+その角度 が範囲。
                    let currentPhaseAngleRange = phaseParameter.getCurrentPhases(currentPhaseNum).toleranceAngle * 2 + 1
                    // 基準角を取得。これがないと重なる可能性がある。
                    let currentPhaseAngle = phaseParameter.getCurrentPhases(currentPhaseNum).userAngle! % currentPhaseAngleRange
                    let anglePerRange = 360 / currentPhaseAngleRange
                    // 全体から random。
                    repeat {
                        resultAngle = fix360(Int(arc4random_uniform(UInt32(anglePerRange))) * currentPhaseAngleRange + currentPhaseAngle)
                    } while resultAngle == fix360(phaseParameter.getCurrentPhases(currentPhaseNum).userAngle!)
                case .plus180XVI: // YM add 2018/01/15，360/currentPhaseAngleRangeに余りのない数が必要。
                    resultAngle = fix360(phaseParameter.getCurrentPhases(currentPhaseNum).userAngle! + 180)
                case .theLeastXVI: // YM add 2018/01/15，360/currentPhaseAngleRangeに余りのない数が必要。
                    // 角度の範囲毎に再計算

                    // 現在の角度の範囲を取得。
                    // ＋ー範囲+その角度 が範囲。
                    let currentPhaseAngleRange = phaseParameter.getCurrentPhases(currentPhaseNum).toleranceAngle * 2 + 1
                    // 基準角を取得。これがないと重なる可能性がある。
                    let currentPhaseAngle = phaseParameter.getCurrentPhases(currentPhaseNum).userAngle! % currentPhaseAngleRange

                    /// 現在の角度の範囲から次の角度を決める。
                    var anglePerUserAngle = [[Int]].init(repeating: [0, 0], count: 360 / currentPhaseAngleRange)
                    for i in 0 ..< anglePerUserAngle.count {
                        // 配列1番目に角度を格納 -> ソート前に追加して角度を保存
                        anglePerUserAngle[i][1] = i * currentPhaseAngleRange
                    }
                    for angle in value.respAngles {
                        // データをUser度ずつ回数カウント
                        anglePerUserAngle[fix360(angle - currentPhaseAngle) / currentPhaseAngleRange][0] += 1
                    }

                    // +180度の配列番目は
                    let angle180 = fix360(phaseParameter.getCurrentPhases(currentPhaseNum).userAngle! - currentPhaseAngle + 180)
                    let angle180ArrayNum = angle180 / currentPhaseAngleRange

                    // カウント逆順にソート
                    anglePerUserAngle.sort { $1[0] > $0[0] }
                    print("anglePerUserAngle: \(anglePerUserAngle)")
                    var array: [Int] = []
                    if anglePerUserAngle.count > 1 {
                        var i = 0
                        while anglePerUserAngle.count > i, anglePerUserAngle[0][0] == anglePerUserAngle[i][0] {
                            print("adperand")
                            array.append(anglePerUserAngle[i][1])
                            i += 1
                        }
                        // 最小の角度の中からランダムに選択
                        resultAngle = fix360(array[Int(arc4random_uniform(UInt32(array.count)))] + currentPhaseAngle)
                    } else {
                        // +180度は
                        let angle180 = fix360(phaseParameter.getCurrentPhases(currentPhaseNum).userAngle! + 180)
                        resultAngle = angle180
                    }
                }
            } else {
                // 一度も反応がない場合，
                resultAngle = Int(arc4random_uniform(36)) * 10
            }
            repeatCount += 1
        } while !decisionChrisOrder(resultAngle, phaseParameter: phaseParameter, repeatCount: repeatCount)
        print("[StoredValue] computeNextTargetAngle() called")
        print("computeNextTargetAngle(): \(resultAngle)")
        return resultAngle
    }

    func decisionChrisOrder(_ resultAngle: Int, phaseParameter: StoredParameterable, repeatCount: Int) -> Bool {
        let nextPhaseNum = currentPhaseNum + 1
        print("decisionChrisOrder() nextPhaseNum:\(nextPhaseNum)")
        if nextPhaseNum == 4 {
            print("decisionChrisOrder() nextPhaseNum:\(nextPhaseNum)")
            let previousPhaseNum = currentPhaseNum - 1
            let previousPhase = phases[previousPhaseNum - 1]
            let previousParameter = phaseParameter.getCurrentPhases(previousPhaseNum)
            let nextParameter = phaseParameter.getCurrentPhases(nextPhaseNum)
            // 今回のコードでは比較が主のため，360で整形しない方が良い。
            if repeatCount < 1000 {
                // 範囲内であれば
                if (previousPhase.targetAngle - previousParameter.toleranceAngle) <= (resultAngle + nextParameter.toleranceAngle), (previousPhase.targetAngle + previousParameter.toleranceAngle) >= (resultAngle - nextParameter.toleranceAngle) {
                    return false
                }
                print("今回のコードでは比較が主のため，360で整形しない方が良い。")
            } else if repeatCount < 5000 {
                // 範囲内であれば
                if (previousPhase.targetAngle - previousParameter.toleranceAngle) >= resultAngle, (previousPhase.targetAngle + previousParameter.toleranceAngle) <= resultAngle {
                    return false
                }
            } else {
                print("Warning does not finish disision loop. function is force return true. at [StoredValue] decisionChrisOrder()")
                return true
            }
        }
        return true
    }
}

class PhaseValue {
    var targetAngle: Int
    var startDate: Date
    var targetResp: Int = 0
    var controlResp: Int = 0
    var unregisterdResp: Int = 0
    var doubleTapResp: Int = 0
    var lastSRresp: Int = 0
    var reinforcers: Int = 0
    var respAngles: [Int] = []
    var allAngles: [Int] = [Int](repeating: 0, count: 361)

    init(targetAngle: Int) {
        self.targetAngle = targetAngle
        self.startDate = Date()
    }
}
