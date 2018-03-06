//
//  CategoryCollectionCell.swift
//  mtrckr
//
//  Created by User on 7/8/17.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!

    func setSelected(selected: Bool, category cat: Category) {
        if selected == true {
            iconView?.layer.borderWidth = 3
            iconView.layer.borderColor = UIColor(cat.color).cgColor
            iconView?.backgroundColor = .white
            icon.tintColor = UIColor(cat.color)
        } else {
            iconView?.layer.borderWidth = 0
            iconView?.backgroundColor = UIColor(cat.color)
            icon.tintColor = .white
        }
    }
}
