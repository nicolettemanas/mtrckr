//
//  StubRegInteractor.swift
//  mtrckr
//
//  Created by User on 6/21/17.
//
//

import UIKit
@testable import mtrckr
import Realm
import RealmSwift

class MockRegInteractor: RealmRegInteractor {
    var didRegister: Bool = false
    
    override func register(withEmail email: String, withEncryptedPassword password: String, withName name: String) {
        didRegister = true
    }
}
