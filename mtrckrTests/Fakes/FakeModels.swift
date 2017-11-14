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
                            "type": r.resolve(AccountType.self, argument: 0)!,
                            "initialAmount": 0,
                            "currentAmount": 0,
                            "totalExpenses": 0,
                            "totalIncome": 0,
                            "color": "#FFFFFF",
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
        container.register(AccountType.self) { (_, id: Int) in
            AccountType(typeId: id, name: "name", icon: "icon")
        }
        container.register(Category.self) { _ in
            mtrckr.Category(id: "CAT-\(NSUUID().uuidString)", type: .expense, name: "name",
                            icon: "icon", color: "#FFFFFF")
        }
        
        container.register(mtrckr.Category.self) { _ in
            mtrckr.Category(id: "CAT-\(NSUUID().uuidString)",
                type: CategoryType.expense,
                name: "name",
                icon: "icon",
                color: "#FFFFFF")
        }
        container.register(Bill.self) { resolver in
            Bill(value: ["id": "BILL-\(NSUUID().uuidString)",
                "amount": 2500,
                "name": "Postpaid Bill",
                "postDueReminder": "never",
                "preDueReminder": "oneDay",
                "repeatSchedule": "monthly",
                "startDate": Date(),
                "category": resolver.resolve(mtrckr.Category.self)!])
        }
        container.register(BillEntry.self) { (_, bill: Bill, date: Date) in
            BillEntry(dueDate: date, for: bill)
        }
        container.register(User.self) { resolver in
            User(id: "USR-\(NSUUID().uuidString)",
                name: "username",
                email: "email",
                image: "",
                currency: resolver.resolve(Currency.self)!)
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
        return self.container.resolve(AccountType.self, argument: id)!
    }
    
    func bill() -> Bill {
        return self.container.resolve(Bill.self)!
    }
    
    func billEntry(for bill: Bill, date: Date) -> BillEntry {
        return self.container.resolve(BillEntry.self, arguments: bill, date)!
    }
    
    func user() -> User {
        return self.container.resolve(User.self)!
    }
    func currency() -> Currency {
        return self.container.resolve(Currency.self)!
    }
}
