//
//  User.swift
//  mtrckr
//
//  Created by User on 4/6/17.
//
//

import UIKit
import RealmSwift
import Realm

class User: Object {
    dynamic var id: String = ""
    
    var accounts = LinkingObjects(fromType: Account.self, property: "user")
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
