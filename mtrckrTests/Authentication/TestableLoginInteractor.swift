//
//  TestableLoginInteractor.swift
//  mtrckr
//
//  Created by User on 6/21/17.
//
//

import UIKit
import RealmSwift
import Realm

@testable import mtrckr

class TestableLoginInteractor: RealmLoginInteractor {
    
    var didLogin = false
    var inMemoryIdentifier: String
    
    init(_ identifier: String) {
        inMemoryIdentifier = identifier
        super.init(with: RealmAuthConfig())
        realmContainer = MockRealmContainer(memoryIdentifier: inMemoryIdentifier)
    }
    
    override func loginUser(withCredentials credentials: SyncCredentials,
                            server: URL, timeout: TimeInterval,
                            completion: @escaping (MTSyncUser?, Error?) -> Void) {
        didLogin = true
        completion(MTSyncUser(), nil)
    }
}

class StubFailedLoginInteractor: RealmLoginInteractor {
    init() {
        super.init(with: RealmAuthConfig())
        realmContainer = MockRealmContainer(memoryIdentifier: "StubFailedLoginInteractor")
    }
    override func loginUser(withCredentials credentials: SyncCredentials,
                            server: URL, timeout: TimeInterval,
                            completion: @escaping (MTSyncUser?, Error?) -> Void) {
        
        let customError = NSError(domain: "", code: 500, userInfo: nil)
        completion(MTSyncUser(), customError as Error)
    }
}
