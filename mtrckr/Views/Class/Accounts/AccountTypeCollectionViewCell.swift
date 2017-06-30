//
//  AccountTypeCollectionViewCell.swift
//  mtrckr
//
//  Created by User on 6/28/17.
//

import UIKit

class AccountTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 0.5
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = MTColors.mainText.cgColor
    }
    
    func didDeselect() {
        contentView.backgroundColor = .white
        icon.tintColor = MTColors.mainText
        name.textColor = MTColors.mainText
    }
    
    func didSelect() {
        contentView.backgroundColor = MTColors.mainText
        icon.tintColor = .white
        name.textColor = .white
    }
}