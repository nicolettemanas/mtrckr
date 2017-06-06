//
//  MTTextField.swift
//  mtrckr
//
//  Created by User on 6/2/17.
//
//

import UIKit
import SkyFloatingLabelTextField

class MTTextField: SkyFloatingLabelTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSkyFloatingLabelProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSkyFloatingLabelProperties()
    }

    func setUpSkyFloatingLabelProperties() {
        self.titleFadeInDuration = 0.2
        self.titleFadeOutDuration = 0.2
        self.lineColor = .lightGray
        self.titleColor = .lightGray
        self.errorColor = .red
        self.selectedTitleColor = .darkGray
        self.selectedLineColor = .darkGray
        self.lineHeight = 2.0
    }
}
