//
//  AccountsCollectionViewDataSource.swift
//  mtrckr
//
//  Created by User on 6/28/17.
//

import UIKit
import Realm
import RealmSwift

protocol AccountTypeCollectionDelegate: class {
    func didSelect(accountType: AccountType)
}

protocol TypeCollectionProtocol {
    weak var delegate: AccountTypeCollectionDelegate? { get set }
    func selectDefault()
    func select(type: AccountType)
    func indexPath(of type: AccountType) -> IndexPath?
}

class AccountTypeCollectionDataSource: RealmHolder, TypeCollectionProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var realm: Realm?
    var notifToken: NotificationToken?
    var types: Results<AccountType>?
    
    weak var collectionView: UICollectionView?
    weak var delegate: AccountTypeCollectionDelegate?
    
    init(with config: AuthConfig, collectionView cv: UICollectionView) {
        super.init(with: config)
        collectionView = cv
        realm = realmContainer?.userRealm
        types = AccountType.all(in: realm!)
        notifToken = realm!.addNotificationBlock({ (_, realm) in
            self.types = AccountType.all(in: realm)
            self.collectionView?.reloadData()
        })
        
        collectionView?.register(UINib(nibName: "AccountTypeCollectionViewCell", bundle: Bundle.main),
                                 forCellWithReuseIdentifier: "AccountTypeCollectionViewCell")
        collectionView?.allowsMultipleSelection = false
        
    }
    
    // MARK: - UICollectionViewDelegate and UICollectionViewDataSource methods
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.types?.count ?? 0
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: AccountTypeCollectionViewCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "AccountTypeCollectionViewCell", for: indexPath)
            as? AccountTypeCollectionViewCell
            else {
                fatalError("Cannot initialize cell with identifier: AccountTypeCollectionViewCell")
            }
        
        guard let type = types?[indexPath.row] else {
            fatalError("Cannot retrieve AccountType")
        }
        cell.name.text = type.name
        cell.icon.image = UIImage(named: type.icon)
        
        cell.contentView.layer.borderWidth = 0.5
        cell.contentView.layer.borderColor = MTColors.mainText.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        if cell.isSelected == true {
            cell.didSelect()
        } else {
            cell.didDeselect()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: AccountTypeCollectionViewCell = collectionView.cellForItem(at: indexPath)
            as? AccountTypeCollectionViewCell else {
            return
        }
        
        cell.didSelect()
        delegate?.didSelect(accountType: types![indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell: AccountTypeCollectionViewCell = collectionView.cellForItem(at: indexPath)
            as? AccountTypeCollectionViewCell else {
                return
        }
        cell.didDeselect()
    }
    
    // MARK: - TypeCollectionProtocol methods
    func selectDefault() {
        guard let cv = collectionView else { return }
        cv.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
        collectionView(cv, didSelectItemAt: IndexPath(row: 0, section: 0))
    }
    
    func select(type: AccountType) {
        guard let cv = collectionView else { return }
        guard let index = indexPath(of: type) else { return }
        cv.selectItem(at: index, animated: true, scrollPosition: .left)
        collectionView(cv, didSelectItemAt: index)
    }
    
    func indexPath(of type: AccountType) -> IndexPath? {
        guard let t = types else { return nil }
        return IndexPath(row: t.index(of: type)!, section: 0)
    }
}
