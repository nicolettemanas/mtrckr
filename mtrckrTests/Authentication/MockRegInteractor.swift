//
//  MockRegInteractor.swift
//  mtrckrTests
//
//  Created by User on 6/26/17.
//

import UIKit
@testable import mtrckr
import Realm
import RealmSwift

class MockRegInteractor: RealmRegInteractor {
    var didRegister = false
    
    init() {
        super.init(with: RealmAuthConfig())
    }
    
    override func registerUser(withCredentials credentials: SyncCredentials, server: URL, timeout: TimeInterval, completion: @escaping (MTSyncUser?, Error?) -> Void) {
        didRegister = true
        output?.didRegister(user: MTSyncUser())
    }
        
}
