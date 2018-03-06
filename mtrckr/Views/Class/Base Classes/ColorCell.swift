//
//  ColorCell.swift
//  mtrckr
//
//  Created by User on 11/8/17.
//

import Foundation
import Eureka

final class ColorRow: Row<ColorCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ColorCell>(nibName: "ColorCell")
    }

    func updateSelection(forType type: TransactionType) {

    }

    override func customUpdateCell() {
        cell.selectionStyle = .none
    }

}

class ColorCell: Cell<UIColor>, CellType {
    @IBOutlet weak var collectionView: UICollectionView!

    var dataSource: ColorsCollectionDataSource?

    override func setup() {
        super.setup()
        dataSource = ColorsCollectionDataSource(value: row.value)
        dataSource?.delegate = self
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        collectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: Bundle.main),
                                forCellWithReuseIdentifier: "ColorCollectionViewCell")
        collectionView.backgroundColor = .clear
        bringSubview(toFront: collectionView)
    }
}

extension ColorCell: ColorsCollectionDelegate {
    func didSelect(color: UIColor) {
        row.value = color
    }
}
