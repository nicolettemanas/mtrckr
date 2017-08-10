//
//  StubTransactionsListDataSource.swift
//  mtrckrTests
//
//  Created by User on 8/8/17.
//

import UIKit
@testable import mtrckr

class StubTransactionsListDataSource: TransactionsListDataSource {
    
    override func reloadByDate(with date: Date) {
        
    }
    
    override func reloadByAccounts(with accounts: [Account]) {
        
    }
    
    override func transaction(at indexPath: IndexPath) -> Transaction? {
        return FakeModels().transaction()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
    }
}
