//
//  MenuRealmParameter.swift
//
//  Created by Yuto Mizutani on 2020/07/21.
//  Copyright © 2020 Yuto Mizutani. All rights reserved.
//

import Foundation
import RealmSwift

class LastID: Object {
    @objc dynamic var id = ""
    @objc dynamic var content = ""

    // Set primaryKey
    override static func primaryKey() -> String? {
        return "id"
    }
}

class MenuRealmParameter: Object {
    // Subjects
    @objc dynamic var id = ""
    @objc dynamic var sessionNum = 1
    @objc dynamic var password = ""
    // Parameter settings
    @objc dynamic var sessionTime = 0
    @objc dynamic var isRotation = false
    // Phase 1
    @objc dynamic var schedule1 = ScheduleRealmType.FR.rawValue
    @objc dynamic var parameter1 = 1
    @objc dynamic var targetAngleType = TargetAngleRealmType.alternativeResponse.rawValue
    @objc dynamic var targetAngle1 = 0
    @objc dynamic var angleRange1 = 45
    @objc dynamic var endType1 = EndRealmType.Time.rawValue
    @objc dynamic var endPara1 = 1
    // Phase 2
    @objc dynamic var schedule2 = ScheduleRealmType.FR.rawValue
    @objc dynamic var parameter2 = 1
    @objc dynamic var angleDetermination = AngleDeterminationRealmType.mix.rawValue
    @objc dynamic var angleRange2 = 45
    @objc dynamic var endType2 = EndRealmType.Time.rawValue
    @objc dynamic var endPara2 = 1
    // Phase 3
    @objc dynamic var schedule3 = ScheduleRealmType.EXT.rawValue
    @objc dynamic var parameter3 = 1
    @objc dynamic var endType3 = EndRealmType.Time.rawValue
    @objc dynamic var endPara3 = 1

    // Set primaryKey
    override static func primaryKey() -> String? {
        return "id"
    }

    static func getIds() throws -> [String] {
        // SchedulesRealm objectに合致するもののみ抽出し，idを配列として返す。
        let realm = try Realm()
        let objects = realm.objects(MenuRealmParameter.self)
        return objects.map { $0.id }
    }
}
