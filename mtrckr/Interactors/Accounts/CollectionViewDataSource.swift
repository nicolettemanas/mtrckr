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

protocol ColorsCollectionDelegate: class {
    func didSelect(color: UIColor)
}

class AccountTypeCollectionDataSource: RealmHolder, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        return CGSize(width: 160, height: 50)
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
    
}

class ColorsCollectionDataSource: RealmHolder, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var collectionView: UICollectionView?
    weak var delegate: ColorsCollectionDelegate?
    
    init(with config: AuthConfig, collectionView cv: UICollectionView) {
        super.init(with: config)
        collectionView = cv
        collectionView?.register(UINib(nibName: "ColorCollectionViewCell", bundle: Bundle.main),
                                 forCellWithReuseIdentifier: "ColorCollectionViewCell")
        collectionView?.allowsMultipleSelection = false
    }
    
    // MARK: - UICollectionViewDelegate and UICollectionViewDataSource methods
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MTColors.colors.count
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ColorCollectionViewCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath)
            as? ColorCollectionViewCell
            else {
                fatalError("Cannot initialize cell with identifier: ColorCollectionViewCell")
        }
        
        if cell.isSelected == true {
            cell.didSelect()
        } else {
            cell.didDeselect()
        }
        
        cell.contentView.backgroundColor = MTColors.colors[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: ColorCollectionViewCell = collectionView.cellForItem(at: indexPath)
            as? ColorCollectionViewCell else {
                return
        }
        
        cell.didSelect()
        delegate?.didSelect(color: MTColors.colors[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell: ColorCollectionViewCell = collectionView.cellForItem(at: indexPath)
            as? ColorCollectionViewCell else {
                return
        }
        cell.didDeselect()
    }
}
