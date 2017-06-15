//
//  MTButton.swift
//  mtrckr
//
//  Created by User on 5/10/17.
//
//

import UIKit

@IBDesignable
class MTButton: UIButton {

    @IBInspectable var hasBorders: Bool = false { didSet { updateBorder() }}
    @IBInspectable var borderColor: UIColor = MTColors.mainBlue { didSet { updateBorder() }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUIProperties() {
        
    }
    
    func updateBorder() {
        if hasBorders {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = borderColor.cgColor
            self.backgroundColor = borderColor
            self.isOpaque = true
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = UIFont.mySystemFont(ofSize: 13)
            self.layer.cornerRadius = self.layer.frame.height/2
        }
    }

}
