//
//  MenuViewController.swift
//
//  Created by YutoMizutani on 2018/01/11.
//  Copyright © 2018 Yuto Mizutani. All rights reserved.
//

import Eureka
import Foundation
import RealmSwift

class MenuViewController: FormViewController {
    let realmID = "load"

    var realm: Realm?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureEureka()
        configureBarItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        getPreviousState()
    }
}

extension MenuViewController {
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

    func configureBarItem() {
        let item = UIBarButtonItem(title: "❮ Back", style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = item
    }
}

// MARK: - about realm

extension MenuViewController {
    /// Session開始時に保存する。
    func saveRealm(_ object: MenuRealmParameter) {
        if object.id != "" {
            do {
                // Realmのインスタンスを取得
                if realm == nil {
                    realm = try Realm()
                }
                // データを追加
                try realm?.write {
                    print("aaa")
                    self.realm?.add(object, update: true)
                }
            } catch {
                print("Realm failed...")
            }

            do {
                // 最後に変更したIDを保存
                let lastObject = LastID()
                lastObject.id = realmID
                lastObject.content = object.id

                // Realmのインスタンスを取得
                if realm == nil {
                    realm = try Realm()
                }
                // データを追加
                try realm?.write {
                    print("aaab")
                    self.realm?.add(lastObject, update: true)
                }
            } catch {
                print("Realm failed...")
            }
        }
    }

    func readUIContents() -> MenuRealmParameter {
        let realmObject = MenuRealmParameter()

        Subjects: do {
            if let idRow = form.rowBy(tag: "IDRow") as? TextRow {
                realmObject.id = idRow.value!
            }
            if let sessionRow = form.rowBy(tag: "SessionRow") as? IntRow {
                realmObject.sessionNum = sessionRow.value!
            }
            if let passwordRow = form.rowBy(tag: "PasswordRow") as? TextRow {
                realmObject.password = passwordRow.value!
            }
        }
        General: do {
            if let sessionTimeRow = form.rowBy(tag: "SessionTimeRow") as? IntRow {
                realmObject.sessionTime = sessionTimeRow.value!
            }
            if let rotationRow = form.rowBy(tag: "RotationRow") as? SwitchRow {
                realmObject.isRotation = rotationRow.value!
                print("realmObject.isRotation = rotationRow.value!: \(realmObject.isRotation) - \(rotationRow.value!)")
            }
        }
        Phase1: do {
            if let parameterRow = form.rowBy(tag: "ParameterRow1") as? IntRow {
                realmObject.parameter1 = parameterRow.value!
            }
            if let scheduleRow = form.rowBy(tag: "ScheduleRow1") as? PickerInputRow<String> {
                realmObject.schedule1 = scheduleRow.value!
            }
            if let targetAngleRow = form.rowBy(tag: "TargetAngleParameter1") as? IntRow {
                realmObject.targetAngle1 = targetAngleRow.value!
            }
            if let targetAngleTypeRow = form.rowBy(tag: "TargetAngleTypeRow1") as? PickerInputRow<String> {
                realmObject.targetAngleType = targetAngleTypeRow.value!
            }
            if let angleRangeRow = form.rowBy(tag: "AngleRange1") as? IntRow {
                realmObject.angleRange1 = angleRangeRow.value!
            }
            if let criterionParameterRow = form.rowBy(tag: "EndParameterRow1") as? IntRow {
                realmObject.endPara1 = criterionParameterRow.value!
            }
            if let criterionTypeRow = form.rowBy(tag: "EndTypeRow1") as? PickerInputRow<String> {
                realmObject.endType1 = criterionTypeRow.value!
            }
        }
        Phase2: do {
            if let parameterRow = form.rowBy(tag: "ParameterRow2") as? IntRow {
                realmObject.parameter2 = parameterRow.value!
            }
            if let scheduleRow = form.rowBy(tag: "ScheduleRow2") as? PickerInputRow<String> {
                realmObject.schedule2 = scheduleRow.value!
            }
            if let angleDeterminationRow = form.rowBy(tag: "AngleDeterminationRow2") as? PickerInputRow<String> {
                realmObject.angleDetermination = angleDeterminationRow.value!
            }
            if let angleRangeRow = form.rowBy(tag: "AngleRange2") as? IntRow {
                realmObject.angleRange2 = angleRangeRow.value!
            }
            if let criterionParameterRow = form.rowBy(tag: "EndParameterRow2") as? IntRow {
                realmObject.endPara2 = criterionParameterRow.value!
            }
            if let criterionTypeRow = form.rowBy(tag: "EndTypeRow2") as? PickerInputRow<String> {
                realmObject.endType2 = criterionTypeRow.value!
            }
        }

        return realmObject
    }

    /// 前回開始した状態を復元する。
    func getPreviousState() {
        do {
            // Realmのインスタンスを取得
            if realm == nil {
                realm = try Realm()
            }

            if let objects = realm?.objects(LastID.self) {
                for object in objects {
                    if object.id == realmID {
                        loadRealm(object.content)
                        return
                    }
                }
            }
        } catch {}

        // 何もない場合は初期化
        let realmObject = MenuRealmParameter()
        readRealm(realmObject)
    }

    /// idを元にUIを変更する。id更新時に呼ばれる。
    func loadRealm(_ id: String) {
        do {
            // Realmのインスタンスを取得
            if realm == nil {
                realm = try Realm()
            }

            if let objects = realm?.objects(MenuRealmParameter.self) {
                for object in objects {
                    if object.id == id {
                        readRealm(object)
                        return
                    }
                }
            }
        } catch {}
    }

    /// 保持objectの更新。
    func readRealm(_ realmObject: MenuRealmParameter) {
        Subjects: do {
            // 空文字を代入できない不具合
//            if let idRow = form.rowBy(tag: "IDRow") as? TextRow {
//                idRow.value = realmObject.id
//                idRow.reload()
//            }
            if let sessionRow = form.rowBy(tag: "SessionRow") as? IntRow {
                sessionRow.value = realmObject.sessionNum
                sessionRow.reload()
            }
            // 空文字を代入できない不具合
//            if let passwordRow = form.rowBy(tag: "PasswordRow") as? TextRow {
//                passwordRow.value = realmObject.password
//                passwordRow.reload()
//            }
        }
        General: do {
            if let sessionTimeRow = form.rowBy(tag: "SessionTimeRow") as? IntRow {
                sessionTimeRow.value = realmObject.sessionTime
                sessionTimeRow.reload()
            }
            if let rotationRow = form.rowBy(tag: "RotationRow") as? SwitchRow {
                rotationRow.value = realmObject.isRotation
                rotationRow.reload()
            }
        }
        Phase1: do {
            if let parameterRow = form.rowBy(tag: "ParameterRow1") as? IntRow {
                parameterRow.value = realmObject.parameter1
                parameterRow.reload()
            }
            if let scheduleRow = form.rowBy(tag: "ScheduleRow1") as? PickerInputRow<String> {
                scheduleRow.value = realmObject.schedule1
                scheduleRow.reload()
            }
            if let targetAngleRow = form.rowBy(tag: "TargetAngleParameter1") as? IntRow {
                targetAngleRow.value = realmObject.targetAngle1
                targetAngleRow.reload()
            }
            if let targetAngleTypeRow = form.rowBy(tag: "TargetAngleTypeRow1") as? PickerInputRow<String> {
                targetAngleTypeRow.value = realmObject.targetAngleType
                targetAngleTypeRow.reload()
            }
            if let angleRangeRow = form.rowBy(tag: "AngleRange1") as? IntRow {
                angleRangeRow.value = realmObject.angleRange1
                angleRangeRow.reload()
            }
            if let criterionParameterRow = form.rowBy(tag: "EndParameterRow1") as? IntRow {
                criterionParameterRow.value = realmObject.endPara1
                criterionParameterRow.reload()
            }
            if let criterionTypeRow = form.rowBy(tag: "EndTypeRow1") as? PickerInputRow<String> {
                criterionTypeRow.value = realmObject.endType1
                criterionTypeRow.reload()
            }
        }
        Phase2: do {
            if let parameterRow = form.rowBy(tag: "ParameterRow2") as? IntRow {
                parameterRow.value = realmObject.parameter2
                parameterRow.reload()
            }
            if let scheduleRow = form.rowBy(tag: "ScheduleRow2") as? PickerInputRow<String> {
                scheduleRow.value = realmObject.schedule2
                scheduleRow.reload()
            }
            if let angleDeterminationRow = form.rowBy(tag: "AngleDeterminationRow2") as? PickerInputRow<String> {
                angleDeterminationRow.value = realmObject.angleDetermination
                angleDeterminationRow.reload()
            }
            if let angleRangeRow = form.rowBy(tag: "AngleRange2") as? IntRow {
                angleRangeRow.value = realmObject.angleRange2
                angleRangeRow.reload()
            }
            if let criterionParameterRow = form.rowBy(tag: "EndParameterRow2") as? IntRow {
                criterionParameterRow.value = realmObject.endPara2
                criterionParameterRow.reload()
            }
            if let criterionTypeRow = form.rowBy(tag: "EndTypeRow2") as? PickerInputRow<String> {
                criterionTypeRow.value = realmObject.endType2
                criterionTypeRow.reload()
            }
        }
    }
}

extension MenuViewController {
    func pushStart(_ isDemo: Bool) {
        let object = readUIContents()
        print("object: \(object)")
        saveRealm(object)
        setValue(isDemo, realmObject: object)
        transition()
    }

    func translateAngleAlgorithm(_ type: AngleDeterminationRealmType) -> AngleAlgorithmType {
        switch type {
        case .straight:
            return AngleAlgorithmType.plus180XVI
        case .least:
            return AngleAlgorithmType.theLeastXVI
        case .mix:
            return AngleAlgorithmType.theLeast180OrAnotherRandom
        case .random:
            return AngleAlgorithmType.random
        }
    }

    func setValue(_ isDemo: Bool, realmObject: MenuRealmParameter) {
        ExperimentViewController.storedParameter = StoredParameterXIII(
            subjectName: realmObject.id,
            sessionNum: realmObject.sessionNum,
            password: realmObject.password,
            sessionTimeMin: realmObject.sessionTime,
            angleAlgorithm: translateAngleAlgorithm(AngleDeterminationRealmType.getType(realmObject.angleDetermination) ?? AngleDeterminationRealmType.mix),
            isUseSensor: realmObject.isRotation,
            isDemo: isDemo
        )

        phase1: do {
            var scheduleType = ScheduleType.FR
            if realmObject.schedule1 == ScheduleRealmType.FR.rawValue {
                scheduleType = ScheduleType.FR
            } else if realmObject.schedule1 == ScheduleRealmType.EXT.rawValue {
                scheduleType = ScheduleType.EXT
            }

            var userAngleValue: Int?
            if realmObject.targetAngleType == TargetAngleRealmType.alternativeResponse.rawValue {
                userAngleValue = nil
            } else if realmObject.targetAngleType == TargetAngleRealmType.angle.rawValue {
                userAngleValue = realmObject.targetAngle1
            }

            var endType = EndType.Time
            if realmObject.endType1 == EndRealmType.SR.rawValue {
                endType = EndType.SR
            } else if realmObject.endType1 == EndRealmType.Swipe.rawValue {
                endType = EndType.Swipe
            } else if realmObject.endType1 == EndRealmType.Time.rawValue {
                endType = EndType.Time
            }

            ExperimentViewController.storedParameter.addPhase(schedule: scheduleType,
                                                              schedParameter: realmObject.parameter1,
                                                              userAngle: userAngleValue,
                                                              toleranceAngle: (realmObject.angleRange1 - 1) / 2,
                                                              endType: endType,
                                                              endParameter: realmObject.endPara1)
        }
        phase2: do {
            var scheduleType = ScheduleType.FR
            if realmObject.schedule2 == ScheduleRealmType.FR.rawValue {
                scheduleType = ScheduleType.FR
            } else if realmObject.schedule2 == ScheduleRealmType.EXT.rawValue {
                scheduleType = ScheduleType.EXT
            }

            var endType = EndType.Time
            if realmObject.endType2 == EndRealmType.SR.rawValue {
                endType = EndType.SR
            } else if realmObject.endType2 == EndRealmType.Swipe.rawValue {
                endType = EndType.Swipe
            } else if realmObject.endType2 == EndRealmType.Time.rawValue {
                endType = EndType.Time
            }

            ExperimentViewController.storedParameter.addPhase(schedule: scheduleType,
                                                              schedParameter: realmObject.parameter2,
                                                              userAngle: nil,
                                                              toleranceAngle: (realmObject.angleRange2 - 1) / 2,
                                                              endType: endType,
                                                              endParameter: realmObject.endPara2)
        }

        do {
            ExperimentViewController.storedParameter.printParameter()
            print(ExperimentViewController.storedParameter.phases[0].schedule)
        }
    }

    func transition() {
        let instructionViewController = InstructionViewController()
        instructionViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(instructionViewController, animated: true, completion: nil)
    }
}
