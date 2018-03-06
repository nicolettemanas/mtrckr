//
//  MockRegInteractor.swift
//  mtrckr
//
//  Created by User on 6/15/17.
//
//

import UIKit
@testable import mtrckr
import RealmSwift
import Realm

class TestableRegInteractor: RealmRegInteractor {
    var didRegister = false
    var inMemoryIdentifier: String
    
    init(_ inMemoryIdentifier: String) {
        self.inMemoryIdentifier = inMemoryIdentifier
        super.init(with: RealmAuthConfig())
        realmContainer = MockRealmContainer(memoryIdentifier: inMemoryIdentifier)
    }
    
    override func registerUser(withCredentials credentials: SyncCredentials,
                               server: URL,
                               timeout: TimeInterval,
                               completion:@escaping (_ user: MTSyncUser?, _ error: Error?) -> Void) {
        didRegister = true
        completion(MTSyncUser(), nil)
    }
}

class StubFailedRegInteractor: RealmRegInteractor {
    
    required init() {
        super.init(with: RealmAuthConfig())
        realmContainer = MockRealmContainer(memoryIdentifier: "StubFailedRegInteractor")
    }
    
    override func registerUser(withCredentials credentials: SyncCredentials, server: URL,
                               timeout: TimeInterval, completion: @escaping (MTSyncUser?, Error?) -> Void) {
        let customError = NSError(domain: "", code: 500, userInfo: nil)
        completion(MTSyncUser(), customError as Error)
    }
}
