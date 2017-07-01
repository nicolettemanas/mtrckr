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
    func selectDefault()
    func select(color: UIColor)
    func indexPath(of color: UIColor) -> IndexPath?
}

class ColorsCollectionDataSource: RealmHolder, ColorCollectionProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    
    // MARK: - ColorCollectionProtocol
    func selectDefault() {
        guard let cv = collectionView else { return }
        cv.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
        collectionView(cv, didSelectItemAt: IndexPath(row: 0, section: 0))
    }
    
    func select(color: UIColor) {
        guard let cv = collectionView else { return }
        guard let index = indexPath(of: color) else { return }
        cv.selectItem(at: index, animated: true, scrollPosition: .left)
        collectionView(cv, didSelectItemAt: index)
    }
    
    func indexPath(of color: UIColor) -> IndexPath? {
        return IndexPath(row: MTColors.colors.index(of: color)!, section: 0)
    }
}
