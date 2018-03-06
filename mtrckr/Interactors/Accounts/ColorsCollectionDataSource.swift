//
//  ColorsCollectionViewDataSource.swift
//  mtrckr
//
//  Created by User on 6/30/17.
//

import UIKit
import Realm
import RealmSwift

protocol ColorsCollectionDelegate: class {
    func didSelect(color: UIColor)
}

protocol ColorCollectionProtocol {
    weak var delegate: ColorsCollectionDelegate? { get set }
    var value: UIColor? { get }
}

class ColorsCollectionDataSource: NSObject, ColorCollectionProtocol {

    weak var delegate: ColorsCollectionDelegate?
    var value: UIColor?

    private var selectedIndexPath: IndexPath?

    init(value aValue: UIColor?) {
        super.init()
        value = aValue
    }
}

extension ColorsCollectionDataSource: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MTColors.colors.count
    }

    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ColorCollectionViewCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath)
            as? ColorCollectionViewCell
            else { fatalError("Cannot initialize cell with identifier: ColorCollectionViewCell") }
        cell.contentView.backgroundColor = MTColors.colors[indexPath.row]

        guard let val = value else { return cell }
        if val == MTColors.colors[indexPath.row] {
            cell.didSelect()
            selectedIndexPath = indexPath
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            delegate?.didSelect(color: MTColors.colors[indexPath.row])
        }
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
        selectedIndexPath = indexPath
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        delegate?.didSelect(color: MTColors.colors[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell: ColorCollectionViewCell = collectionView.cellForItem(at: indexPath)
            as? ColorCollectionViewCell else {
                return
        }
        cell.didDeselect()
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        guard let aCell = cell as? ColorCollectionViewCell else { return }
        aCell.didDeselect()
        if selectedIndexPath == indexPath { aCell.didSelect() }
    }
}
