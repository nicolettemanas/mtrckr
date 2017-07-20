//
//  TransactionCalendarCell.swift
//  mtrckr
//
//  Created by User on 7/17/17.
//

import UIKit
import FSCalendar

class TransactionCalendarCell: FSCalendarCell {
    
    var customSelectionView: UIView!
    var selectionLayer: CAShapeLayer!
    var incomeSubtitleLabel: UILabel!
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.shapeLayer.isHidden = true
        self.shapeLayer.frame = frame
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = MTColors.subRed.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        
        self.selectionLayer = selectionLayer
        self.selectionLayer.borderColor = MTColors.mainRed.cgColor
        self.selectionLayer.borderWidth = 0.5
        
        self.customSelectionView = UIView(frame: self.bounds)
        self.customSelectionView.backgroundColor = UIColor("#D6EEFF")
        self.customSelectionView.isHidden = true
        self.customSelectionView.layer.borderWidth = 0.5
        self.customSelectionView.layer.borderColor = MTColors.mainBlue.cgColor
        self.contentView.insertSubview(self.customSelectionView, belowSubview: self.titleLabel)
        
        self.incomeSubtitleLabel = UILabel(frame: .zero)
        self.contentView.insertSubview(self.incomeSubtitleLabel, belowSubview: self.titleLabel)
        
        self.titleLabel.textAlignment = .right
        self.subtitleLabel.textAlignment = .right
        self.incomeSubtitleLabel.textAlignment = .right
        
        self.subtitleLabel.textColor = MTColors.mainRed
        self.incomeSubtitleLabel.textColor = MTColors.mainGreen
        
        self.titleLabel.font = UIFont.mySystemFont(ofSize: 12)
        self.incomeSubtitleLabel.font = UIFont.mySystemFont(ofSize: 8)
        self.subtitleLabel.font = UIFont.mySystemFont(ofSize: 8)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = CGRect(x: frame.origin.x-10, y: frame.origin.y,
                            width: frame.size.width,
                            height: frame.size.height)
        
        self.selectionLayer.frame = self.contentView.bounds
        self.subtitleLabel.frame = CGRect(x: self.subtitleLabel.frame.origin.x + 5,
                                          y: self.subtitleLabel.frame.origin.y + 5,
                                          width: self.subtitleLabel.frame.size.width - 10,
                                          height: 10)
        self.incomeSubtitleLabel.frame = CGRect(x: self.subtitleLabel.frame.origin.x,
                                                y: self.subtitleLabel.frame.origin.y + 10,
                                                width: self.subtitleLabel.frame.size.width,
                                                height: 10)
        self.titleLabel.frame = CGRect(x: self.titleLabel.frame.origin.x,
                                          y: self.titleLabel.frame.origin.y,
                                          width: self.titleLabel.frame.size.width - 8,
                                          height: self.titleLabel.frame.size.height)
        self.selectionLayer.path = UIBezierPath(roundedRect: self.contentView.frame, cornerRadius: 0).cgPath
    }
}
