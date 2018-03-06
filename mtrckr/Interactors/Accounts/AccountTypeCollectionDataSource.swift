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

protocol AccountTypeCollectionDataSourceProtocol {
    weak var delegate: AccountTypeCollectionDelegate? { get set }
    var value: AccountType? { get }
}

class AccountTypeCollectionDataSource: RealmHolder, AccountTypeCollectionDataSourceProtocol {

    var realm: Realm?
    var types: Results<AccountType>?

    weak var delegate: AccountTypeCollectionDelegate?
    var value: AccountType?

    private var selectedIndexPath: IndexPath?

    init(with config: AuthConfig, value aValue: AccountType?) {
        super.init(with: config)
        realm = realmContainer?.userRealm
        types = AccountType.all(in: realm!)
        value = aValue
    }

    func type(atIndex index: IndexPath) -> AccountType? {
        return types?[index.row]
    }
}

extension AccountTypeCollectionDataSource: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.types?.count ?? 0
    }

    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: AccountTypeCollectionViewCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "AccountTypeCollectionViewCell", for: indexPath)
            as? AccountTypeCollectionViewCell
            else { fatalError("Cannot initialize cell with identifier: AccountTypeCollectionViewCell") }

        guard let type = types?[indexPath.row] else {
            fatalError("Cannot retrieve AccountType")
        }

        cell.icon.image = UIImage(named: type.icon)
        guard let val = value else { return cell }

        if val.typeId == type.typeId {
            cell.didSelect()
            selectedIndexPath = indexPath
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            delegate?.didSelect(accountType: types![indexPath.row])
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: AccountTypeCollectionViewCell = collectionView.cellForItem(at: indexPath)
            as? AccountTypeCollectionViewCell else { return }

        cell.didSelect()
        selectedIndexPath = indexPath
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        delegate?.didSelect(accountType: types![indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell: AccountTypeCollectionViewCell = collectionView.cellForItem(at: indexPath)
            as? AccountTypeCollectionViewCell else { return }
        cell.didDeselect()
        guard let type = type(atIndex: indexPath) else { return }
        delegate?.didSelect(accountType: type)
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let aCell = cell as? AccountTypeCollectionViewCell else { return }
        aCell.didDeselect()
        if selectedIndexPath == indexPath { aCell.didSelect() }
    }
}
