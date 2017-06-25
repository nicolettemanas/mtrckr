//
//  MTButton.swift
//  mtrckr
//
//  Created by User on 5/10/17.
//
//

import UIKit

/// Base class for UIButtons
@IBDesignable
class MTButton: UIButton {
    
    // MARK: - Properties
    
    /// Boolean value indicating whether to render the button with borders
    @IBInspectable var hasBorders: Bool = false { didSet { updateBorder() }}
    
    /// UIColor of the border to be rendered
    @IBInspectable var borderColor: UIColor = MTColors.mainBlue { didSet { updateBorder() }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
