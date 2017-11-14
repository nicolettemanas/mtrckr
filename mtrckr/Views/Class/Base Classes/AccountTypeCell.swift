//
//  AccountTypeCell.swift
//  mtrckr
//
//  Created by User on 11/6/17.
//

import Foundation
import Eureka
import UIKit

final class AccountTypeRow: Row<AccountTypeCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<AccountTypeCell>(nibName: "AccountTypeCell")
    }
    
    override func customUpdateCell() {
        cell.selectionStyle = .none
    }
    
    func updateSelection(forType type: TransactionType) {
        
    }
}

class AccountTypeCell: Cell<AccountType>, CellType {
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: AccountTypeCollectionDataSource?
    
    override func setup() {
        super.setup()
        dataSource = MTResolver().container.resolve(AccountTypeCollectionDataSource.self, argument: row.value)
//        dataSource?.value = row.value
        dataSource?.delegate = self
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        collectionView.register(UINib(nibName: "AccountTypeCollectionViewCell", bundle: Bundle.main),
                                forCellWithReuseIdentifier: "AccountTypeCollectionViewCell")
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        bringSubview(toFront: collectionView)
    }
}

extension AccountTypeCell: AccountTypeCollectionDelegate {
    func didSelect(accountType: AccountType) {
        row.value = accountType
    }
}
