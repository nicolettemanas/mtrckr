//
//  CategoryCell.swift
//  mtrckr
//
//  Created by User on 7/8/17.
//

import UIKit
import Eureka
import Realm
import RealmSwift

protocol CategoryDataSourceProtocol {
    var categories: Results<Category>? { get }
    var collectionView: UICollectionView? { get set }
    var value: Category? { get set }
    var delegate: CategoryDataSourceDelegate? { get set }
    func selectItem(at indexPath: IndexPath)
    func updateSelection(forType type: TransactionType)
}

protocol CategoryDataSourceDelegate: class {
    func didSelect(category: Category)
}

final class CategoryRow: Row<CategoryCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<CategoryCell>(nibName: "CategoryCell")
    }
    
    func updateSelection(forType type: TransactionType) {
        cell?.updateSelection(forType: type)
    }
    
    override func customUpdateCell() {
        cell.selectionStyle = .none
    }
}

class CategoryCell: Cell<Category>, CellType, CategoryDataSourceDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: CategoryDataSourceProtocol?
    
    override func setup() {
        super.setup()
        dataSource = CategoryDataSource(with: RealmAuthConfig(), ofType: .expense, collectionView: collectionView)
        dataSource?.value = row.value
        dataSource?.delegate = self
        collectionView.dataSource = dataSource as? UICollectionViewDataSource
        collectionView.delegate = dataSource as? UICollectionViewDelegate
        collectionView.register(UINib(nibName: "CategoryCollectionCell", bundle: Bundle.main),
                                forCellWithReuseIdentifier: "CategoryCollectionCell")
        collectionView.backgroundColor = .clear
        bringSubview(toFront: collectionView)
    }
    
    override func update() {
        super.update()
    }
    
    func selectItem(at indexPath: IndexPath) {
        dataSource?.selectItem(at: indexPath)
    }
    
    func updateSelection(forType type: TransactionType) {
        dataSource?.updateSelection(forType: type)
        row.value = nil
    }
    
    // MARK: - CategoryDataSourceDelegate methods
    func didSelect(category: Category) {
        row.value = category
    }
}
