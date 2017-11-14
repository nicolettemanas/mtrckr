//
//  CategoryDataSource.swift
//  mtrckr
//
//  Created by User on 11/6/17.
//

import Foundation
import UIKit
import RealmSwift

class CategoryDataSource: RealmHolder, CategoryDataSourceProtocol {
    
    var categories: Results<Category>?
    var value: Category?
    
    weak var collectionView: UICollectionView?
    weak var delegate: CategoryDataSourceDelegate?
    
    private let numOfItemsPerSection = 5
    private var numOfSections = 0
    
    deinit {
        print("DEINIT: \(self)")
    }
    
    // MARK: - Initializers
    init(with config: AuthConfig, ofType ty: CategoryType, collectionView cv: UICollectionView) {
        super.init(with: config)
        collectionView = cv
        updateSelection(forType: TransactionType(rawValue: ty.rawValue)!)
    }
    
    // MARK: - CategoryDataSourceProtocol methods
    func selectItem(at indexPath: IndexPath) {
        collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        collectionView(collectionView!, didSelectItemAt: indexPath)
    }
    
    func updateSelection(forType type: TransactionType) {
        if type != .transfer {
            categories = Category.all(in: realmContainer!.userRealm!, ofType: CategoryType(rawValue: type.rawValue)!)
            numOfSections = (categories!.count/numOfItemsPerSection) + 1
            collectionView?.reloadData()
        }
    }
    
    // MARK: - Util methods
    private func index(from indexPath: IndexPath) -> Int {
        return indexPath.item + (indexPath.section * numOfItemsPerSection)
    }
}

extension CategoryDataSource: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numOfSections
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == numOfSections - 1 { return categories!.count % numOfItemsPerSection }
        return numOfItemsPerSection
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell",
                                                            for: indexPath) as? CategoryCollectionCell
            else {
                fatalError("Cannot find nib CategoryCollectionCell")
        }
        
        let cat = categories![index(from: indexPath)]
        cell.iconView.backgroundColor = UIColor(cat.color)
        cell.iconView.layer.cornerRadius = 10
        cell.iconView.layer.masksToBounds = true
        cell.icon.image = UIImage(named: cat.icon)
        cell.label.text = cat.name
        
        if cat == value {
            cell.isSelected = true
        }
        cell.setSelected(selected: cell.isSelected, category: cat)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionCell {
            let cat = categories![index(from: indexPath)]
            cell.setSelected(selected: true, category: cat)
            delegate?.didSelect(category: cat)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionCell {
            let cat = categories![index(from: indexPath)]
            cell.setSelected(selected: false, category: cat)
        }
    }
}
