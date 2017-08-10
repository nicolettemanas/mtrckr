//
//  Fakes.swift
//  mtrckrTests
//
//  Created by User on 8/6/17.
//

import UIKit
import Swinject
@testable import mtrckr

class FakeModels {
    var container = Container()
    
    init() {
        container.register(Currency.self) { _ in
            Currency(id: "currency-\(NSUUID().uuidString)", isoCode: "iso", symbol: "symbol", state: "state")
        }
        container.register(User.self) { r in
            User(id: "user-\(NSUUID().uuidString)", name: "name", email: "email", image: "image",
                 currency: r.resolve(Currency.self)!)
        }
        container.register(Account.self) { r in
            Account(value: ["id": "ACC-\(NSUUID().uuidString)",
                            "name": "name",
                            "type": r.resolve(AccountType.self)!,
                            "initialAmount": 0,
                            "currentAmount": 0,
                            "totalExpenses": 0,
                            "totalIncome": 0,
                            "color": "color",
                            "dateOpened": Date()
                ])
        }
        container.register(Transaction.self) { r in
            Transaction(type: .expense, name: "name",
                        image: "image", description: "description",
                        amount: 0, category: r.resolve(mtrckr.Category.self)!,
                        from: r.resolve(Account.self)!, to: r.resolve(Account.self)!,
                        date: Date())
        }
        container.register(AccountType.self) { _ in
            AccountType(typeId: 0, name: "name", icon: "icon")
        }
        container.register(Category.self) { _ in
            mtrckr.Category(id: "CAT-\(NSUUID().uuidString)", type: .expense, name: "name",
                            icon: "icon", color: "color")
        }
    }
    
    func transaction() -> Transaction {
        return self.container.resolve(Transaction.self)!
    }
    
    func category() -> mtrckr.Category {
        return self.container.resolve(mtrckr.Category.self)!
    }
    
    func account() -> Account {
        return self.container.resolve(Account.self)!
    }
    
    func accountType(id: Int) -> AccountType {
        let type = self.container.resolve(AccountType.self)
        type?.typeId = id
        return type!
    }
}
