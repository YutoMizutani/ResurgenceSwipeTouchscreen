//
//  EurekaXVI.swift
//
//  Created by YutoMizutani on 2018/01/11.
//  Copyright © 2018 Yuto Mizutani. All rights reserved.
//

import Eureka
import Foundation

extension MenuViewController {
    func configureEureka() {
        configureSection()

        titleSection()
        subjectsSection()
        parameterSection()
        startSection()

        endSection()
    }
}

// MARK: - Header and Footer

private struct CreateHeader {
    // 太字のヘッダーを作成。
    static func create(_ title: String) -> HeaderFooterView<UILabel> {
        let tableSectionHeaderViewHeightParameter: CGFloat = 50
        let tableBackgroundColor = UIColor(red: 0xEF / 255.0, green: 0xEF / 255.0, blue: 0xF4 / 255.0, alpha: 1.0)

        var header = HeaderFooterView<UILabel>(.class)
        header.height = { tableSectionHeaderViewHeightParameter }
        header.onSetupView = { view, _ in
            view.backgroundColor = tableBackgroundColor
            view.frame.size.height = tableSectionHeaderViewHeightParameter
            view.textColor = UIColor.black
            let strBlank: String = "   " + title
            view.text = strBlank
            view.font = UIFont.boldSystemFont(ofSize: 25)
            view.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        }

        return header
    }
}

private struct CreateFooter {
    // 高さ0のフッターを作成。
    static func create() -> HeaderFooterView<UIView> {
        var footer = HeaderFooterView<UIView>(.class)
        footer.height = { 0 }
        return footer
    }
}

// MARK: - Eureka

extension MenuViewController {
    fileprivate func configureSection() {
        // Error validation label
        ErrorValidationLabel: do {
            LabelRow.estimatedRowHeight = 30 // ???: 反映されていない？ cannot work at https://github.com/xmartlabs/Eureka/issues/296
            LabelRow.defaultCellUpdate = { cell, _ in
                cell.contentView.backgroundColor = .red
                cell.textLabel?.textColor = .white
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                cell.textLabel?.textAlignment = .right
            }
        }
    }

    fileprivate func titleSection() {
        form
            // Title
            +++ Section { section in
                section.header = CreateHeader.create("")
            }
    }

    fileprivate func subjectsSection() {
        form
            // General settings
            +++ Section("SubjectsSection") { section in
                section.header = CreateHeader.create("Subjects")
                section.footer = CreateHeader.create("")
            }

            <<< TextRow("IDRow") {
                // Title
                $0.title = "ID:"

                // Default value
                $0.value = ""

                // Validation
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    if rowValue == nil || rowValue! == "" { // 空白
                        return ValidationError(msg: "Field required")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }

            <<< IntRow("SessionRow") {
                // Title
                $0.title = "Session#:"

                // value
                $0.value = 1

                // Validation
                let ruleRequiredViaClosure = RuleClosure<Int> { rowValue in
                    if rowValue == nil { // 空白
                        return ValidationError(msg: "Field required")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }

            <<< TextRow("PasswordRow") {
                // Title
                $0.title = "Password:"

                // Default value
                $0.value = ""

                // Validation
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    if rowValue == nil || rowValue! == "" { // 空白
                        return ValidationError(msg: "Field required")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
    }

    fileprivate func parameterSection() {
        form
            // Parameter settings
            +++ Section("ParameterSection") { section in
                section.header = CreateHeader.create("Parameter settings")
                section.footer = CreateHeader.create("")
            }

            // MARK: - General

            <<< TextRow("General") {
                // Title
                $0.title = "General"

                // Bold font
                $0.cell.titleLabel?.font = UIFont.boldSystemFont(ofSize: $0.cell.titleLabel!.font.pointSize)

                // Disabled (do not user edit)
                $0.disabled = Eureka.Condition.function([]) { _ -> Bool in return true }
            }
            .cellUpdate { cell, _ in
                // Set color when disabled
                cell.titleLabel?.textColor = .black
            }

            <<< IntRow("SessionTimeRow") {
                // Title
                $0.title = "        SessionTime (min):"

                // value
                $0.value = 0

                // Validation
                let ruleRequiredViaClosure = RuleClosure<Int> { rowValue in
                    if rowValue == nil { // 空白
                        return ValidationError(msg: "Field required")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }

            <<< SwitchRow("RotationRow") {
                // Title
                $0.title = "        Rotation"

                // value
                $0.value = false
            }

            // MARK: - Phase 1

            <<< TextRow("PhaseRow1") {
                // Title
                $0.title = "Phase 1"

                // Bold font
                $0.cell.titleLabel?.font = UIFont.boldSystemFont(ofSize: $0.cell.titleLabel!.font.pointSize)

                // Disabled (do not user edit)
                $0.disabled = Eureka.Condition.function([]) { _ -> Bool in return true }
            }
            .cellUpdate { cell, _ in
                // Set color when disabled
                cell.titleLabel?.textColor = .black
            }

            <<< PickerInputRow<String>("ScheduleRow1") {
            // Title
            $0.title = "        Schedule:"

            // Picker contents
            $0.options = []
            for type in ScheduleRealmType.allCases {
                $0.options.append(type.rawValue)
            }

            // Default value
            $0.value = $0.options[0]
        }

            <<< IntRow("ParameterRow1") {
                // Title
                $0.title = "            Parameter:"

                // value
                $0.value = 0

                // Hidden
                $0.hidden = .function(["ScheduleRow1"]) { form -> Bool in
                    let row: PickerInputRow<String>! = form.rowBy(tag: "ScheduleRow1")
                    return row.value! == ScheduleRealmType.EXT.rawValue
                }

                // Validation
                let ruleRequiredViaClosure = RuleClosure<Int> { rowValue in
                    if rowValue == nil { // 空白
                        return ValidationError(msg: "Field required")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }

            <<< PickerInputRow<String>("TargetAngleTypeRow1") {
            // Title
            $0.title = "        Target angle type:"

            // Picker contents
            $0.options = []
            for type in TargetAngleRealmType.allCases {
                $0.options.append(type.rawValue)
            }

            // Default value
            $0.value = $0.options[0]
        }

            <<< IntRow("TargetAngleParameter1") {
                // Title
                $0.title = "            Target angle:"

                // value
                $0.value = 0

                // Hidden
                $0.hidden = .function(["TargetAngleTypeRow1"]) { form -> Bool in
                    let row: PickerInputRow<String>! = form.rowBy(tag: "TargetAngleTypeRow1")
                    return row.value! != TargetAngleRealmType.angle.rawValue
                }

                // Validation
                let ruleRequiredViaClosure = RuleClosure<Int> { rowValue in
                    if rowValue == nil { // 空白
                        return ValidationError(msg: "Field required")
                    } else if rowValue! > 360 { // 360以上指定
                        return ValidationError(msg: "This value cannot over 360 degree")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }

            <<< IntRow("AngleRange1") {
                // Title
                $0.title = "        Angle range:"

                // value
                $0.value = 0

                // Validation
                let ruleRequiredViaClosure = RuleClosure<Int> { rowValue in
                    if rowValue == nil { // 空白
                        return ValidationError(msg: "Field required")
                    } else if rowValue! > 360 { // 360以上指定
                        return ValidationError(msg: "This value cannot over 360 degree")
                    } else if rowValue! % 2 != 1 { // 偶数指定
                        return ValidationError(msg: "This value is not odd")
                    } else if 360 % rowValue! != 0 { // 360を割り切れない場合; 360%11 != 0
                        return ValidationError(msg: "There is a remainder after dividing this value from 360")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }

            <<< PickerInputRow<String>("EndTypeRow1") {
            // Title
            $0.title = "        Criterion to end phase:"

            // Picker contents
            $0.options = []
            for type in EndRealmType.allCases {
                $0.options.append(type.rawValue)
            }

            // Default value
            $0.value = $0.options[0]
        }

            <<< IntRow("EndParameterRow1") {
                // Title
                $0.title = "            parameter (swipe/SR/min):"

                // value
                $0.value = 0

                // Validation
                let ruleRequiredViaClosure = RuleClosure<Int> { rowValue in
                    if rowValue == nil { // 空白
                        return ValidationError(msg: "Field required")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }

            // MARK: - Phase 2

            <<< TextRow("PhaseRow2") {
                // Title
                $0.title = "Phase 2"

                // Bold font
                $0.cell.titleLabel?.font = UIFont.boldSystemFont(ofSize: $0.cell.titleLabel!.font.pointSize)

                // Disabled (do not user edit)
                $0.disabled = Eureka.Condition.function([]) { _ -> Bool in return true }
            }
            .cellUpdate { cell, _ in
                // Set color when disabled
                cell.titleLabel?.textColor = .black
            }

            <<< PickerInputRow<String>("ScheduleRow2") {
            // Title
            $0.title = "        Schedule:"

            // Picker contents
            $0.options = []
            for type in ScheduleRealmType.allCases {
                $0.options.append(type.rawValue)
            }

            // Default value
            $0.value = $0.options[0]
        }

            <<< IntRow("ParameterRow2") {
                // Title
                $0.title = "            Parameter:"

                // value
                $0.value = 0

                // Hidden
                $0.hidden = .function(["ScheduleRow2"]) { form -> Bool in
                    let row: PickerInputRow<String>! = form.rowBy(tag: "ScheduleRow2")
                    return row.value! == ScheduleRealmType.EXT.rawValue
                }

                // Validation
                let ruleRequiredViaClosure = RuleClosure<Int> { rowValue in
                    if rowValue == nil { // 空白
                        return ValidationError(msg: "Field required")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }

            <<< PickerInputRow<String>("AngleDeterminationRow2") {
            // Title
            $0.title = "        Angle determination:"

            // Picker contents
            $0.options = []
            for type in AngleDeterminationRealmType.allCases {
                $0.options.append(type.rawValue)
            }

            // Default value
            $0.value = $0.options[0]
        }

            <<< IntRow("AngleRange2") {
                // Title
                $0.title = "        Angle range:"

                // value
                $0.value = 0

                // Validation
                let ruleRequiredViaClosure = RuleClosure<Int> { rowValue in
                    if rowValue == nil { // 空白
                        return ValidationError(msg: "Field required")
                    } else if rowValue! > 360 { // 360以上指定
                        return ValidationError(msg: "This value cannot over 360 degree")
                    } else if rowValue! % 2 != 1 { // 偶数指定
                        return ValidationError(msg: "This value is not odd")
                    } else if 360 % rowValue! != 0 { // 360を割り切れない場合; 360%11 != 0
                        return ValidationError(msg: "There is a remainder after dividing this value from 360")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }

            <<< PickerInputRow<String>("EndTypeRow2") {
            // Title
            $0.title = "        Criterion to end phase:"

            // Picker contents
            $0.options = []
            for type in EndRealmType.allCases {
                $0.options.append(type.rawValue)
            }

            // Default value
            $0.value = $0.options[0]
        }

            <<< IntRow("EndParameterRow2") {
                // Title
                $0.title = "            parameter (swipe/SR/min):"

                // value
                $0.value = 0

                // Validation
                let ruleRequiredViaClosure = RuleClosure<Int> { rowValue in
                    if rowValue == nil { // 空白
                        return ValidationError(msg: "Field required")
                    } else {
                        return nil
                    }
                }
                $0.add(rule: ruleRequiredViaClosure)

                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow {
                            $0.title = validationMsg
                            //                            $0.cell.height = { 30 }
                            $0.cell.frame.size.height = 30
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
    }

    fileprivate func startSection() {
        form
            +++ Section("StartSection") { section in
                section.header = CreateHeader.create("Start")
            }

            // Compute button
            <<< ButtonRow("Demo") {
                // Title
                $0.title = $0.tag

                // Bold font
                $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: $0.cell.textLabel!.font.pointSize)

                // Disabled
                $0.disabled = Eureka.Condition.function(["IDRow", "SessionRow", "PasswordRow", "SessionTimeRow", "ParameterRow1", "TargetAngleParameter1", "AngleRange1", "EndParameterRow1", "ParameterRow2", "AngleRange2", "EndParameterRow2"]) { form -> Bool in
                    let IDRow = (form.rowBy(tag: "IDRow") as? TextRow)?.isValid ?? false
                    let SessionRow = (form.rowBy(tag: "SessionRow") as? IntRow)?.isValid ?? false
                    let PasswordRow = (form.rowBy(tag: "PasswordRow") as? TextRow)?.isValid ?? false
                    let SessionTimeRow = (form.rowBy(tag: "SessionTimeRow") as? IntRow)?.isValid ?? false
                    let ParameterRow1 = (form.rowBy(tag: "ParameterRow1") as? IntRow)?.isValid ?? false
                    let TargetAngleParameter1 = (form.rowBy(tag: "TargetAngleParameter1") as? IntRow)?.isValid ?? false
                    let AngleRange1 = (form.rowBy(tag: "AngleRange1") as? IntRow)?.isValid ?? false
                    let EndParameterRow1 = (form.rowBy(tag: "EndParameterRow1") as? IntRow)?.isValid ?? false
                    let ParameterRow2 = (form.rowBy(tag: "ParameterRow2") as? IntRow)?.isValid ?? false
                    let AngleRange2 = (form.rowBy(tag: "AngleRange2") as? IntRow)?.isValid ?? false
                    let EndParameterRow2 = (form.rowBy(tag: "EndParameterRow2") as? IntRow)?.isValid ?? false
                    return !(IDRow && SessionRow && PasswordRow && SessionTimeRow && ParameterRow1 && TargetAngleParameter1 && AngleRange1 && EndParameterRow1 && ParameterRow2 && AngleRange2 && EndParameterRow2)
                }
            }
            .onCellSelection { [weak self] _, row in
                if !row.isDisabled {
                    self?.pushStart(true)
                }
            }

            // Compute button
            <<< ButtonRow("Start") {
                // Title
                $0.title = $0.tag

                // Bold font
                $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: $0.cell.textLabel!.font.pointSize)

                // Disabled
                $0.evaluateDisabled()
                $0.disabled = Eureka.Condition.function(["IDRow", "SessionRow", "PasswordRow", "SessionTimeRow", "ParameterRow1", "TargetAngleParameter1", "AngleRange1", "EndParameterRow1", "ParameterRow2", "AngleRange2"]) { form -> Bool in
                    let IDRow = (form.rowBy(tag: "IDRow") as? TextRow)?.isValid ?? false
                    let SessionRow = (form.rowBy(tag: "SessionRow") as? IntRow)?.isValid ?? false
                    let PasswordRow = (form.rowBy(tag: "PasswordRow") as? TextRow)?.isValid ?? false
                    let SessionTimeRow = (form.rowBy(tag: "SessionTimeRow") as? IntRow)?.isValid ?? false
                    let ParameterRow1 = (form.rowBy(tag: "ParameterRow1") as? IntRow)?.isValid ?? false
                    let TargetAngleParameter1 = (form.rowBy(tag: "TargetAngleParameter1") as? IntRow)?.isValid ?? false
                    let AngleRange1 = (form.rowBy(tag: "AngleRange1") as? IntRow)?.isValid ?? false
                    let EndParameterRow1 = (form.rowBy(tag: "EndParameterRow1") as? IntRow)?.isValid ?? false
                    let ParameterRow2 = (form.rowBy(tag: "ParameterRow2") as? IntRow)?.isValid ?? false
                    let AngleRange2 = (form.rowBy(tag: "AngleRange2") as? IntRow)?.isValid ?? false
                    let EndParameterRow2 = (form.rowBy(tag: "EndParameterRow2") as? IntRow)?.isValid ?? false
                    return !(IDRow && SessionRow && PasswordRow && SessionTimeRow && ParameterRow1 && TargetAngleParameter1 && AngleRange1 && EndParameterRow1 && ParameterRow2 && AngleRange2 && EndParameterRow2)
                }
            }
            .onCellSelection { [weak self] _, row in
                if !row.isDisabled {
                    self?.pushStart(false)
                }
            }
    }

    fileprivate func endSection() {
        form
            +++ Section()
            +++ Section()
            +++ Section()
    }
}
