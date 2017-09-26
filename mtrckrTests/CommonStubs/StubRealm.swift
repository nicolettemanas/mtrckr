//
//  StubRealm.swift
//  mtrckrTests
//
//  Created by User on 8/17/17.
//

import UIKit
import RealmSwift
@testable import mtrckr

class StubRealm: RealmHolder {
    var fakeModel = FakeModels()
    
    init(identifier: String) {
        super.init(with: RealmAuthConfig())
        self.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
        self.realmContainer?.setDefaultRealm(to: .offline)
        
        try? self.realmContainer!.userRealm!.write {
            self.realmContainer!.userRealm!.deleteAll()
        }
        
        let currency = self.fakeModel.currency()
        currency.save(toRealm: self.realmContainer!.userRealm!)
        
        let user = self.fakeModel.user()
        user.save(toRealm: self.realmContainer!.userRealm!)
        for i in 0..<5 {
            let accountType = self.fakeModel.accountType(id: 100 + i)
            let account = self.fakeModel.account()
            let cat = self.fakeModel.category()
            accountType.save(toRealm: self.realmContainer!.userRealm!)
            account.type = accountType
            account.save(toRealm: self.realmContainer!.userRealm!)
            cat.save(toRealm: self.realmContainer!.userRealm!)
        }
    }
}
