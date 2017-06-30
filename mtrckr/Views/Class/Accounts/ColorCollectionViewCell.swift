//
//  ColorCollectionViewCell.swift
//  mtrckr
//
//  Created by User on 6/29/17.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var checkIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        checkIcon.contentMode = .scaleAspectFit
        checkIcon.tintColor = .white
    }
    
    func didSelect() {
        self.checkIcon.isHidden = false
    }
    
    func didDeselect() {
        self.checkIcon.isHidden = true
    }
}
