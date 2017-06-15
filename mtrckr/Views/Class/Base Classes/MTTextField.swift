//
//  MTTextField.swift
//  mtrckr
//
//  Created by User on 6/2/17.
//
//

import UIKit
import SkyFloatingLabelTextField

@IBDesignable
class MTTextField: UITextField {

    @IBInspectable var bottomBorderColor: UIColor = MTColors.mainBlue { didSet { updateBorder() }}
    @IBInspectable var icon: UIImage = MTTextField.getDefaultImage() { didSet { updateIcon() }}
    @IBInspectable var iconColor: UIColor = MTColors.mainBg { didSet { updateIconColor() }}
    
    private var leftIcon: UIImageView?
    private var warningIcon: UIImageView?
    
    private var errorLabel: UILabel?
    private var errorContainer: UIView?
    private var border: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = false
    }
    
    class func getDefaultImage() -> UIImage {
        return UIImage()
    }

    func setupUI() {
        self.textColor = MTColors.mainText
        if let p = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: p,
                                                            attributes: [NSForegroundColorAttributeName:
                                                                MTColors.subText])
        }
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        let imageHolder = UIImageView(frame: CGRect(x: 0, y: 2, width: 20, height: 20))
        imageHolder.contentMode = .scaleAspectFit
        imageHolder.image = UIImage(named: "warning")?.withRenderingMode(.alwaysTemplate)
        imageHolder.tintColor = MTColors.mainRed
        
        containerView.addSubview(imageHolder)
        warningIcon = imageHolder
        self.rightViewMode = .never
        self.rightView = containerView
        self.rightView?.alpha = 0.8
        
        errorContainer = UIView(frame: CGRect(x: 0, y: self.frame.size.height/2, width: self.frame.size.width, height: 15))
        errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 15))
        errorLabel?.textColor = MTColors.mainRed
        errorLabel?.font = UIFont.systemFont(ofSize: 12)
        errorContainer?.isHidden = true
        
        errorContainer?.addSubview(errorLabel!)
        self.addSubview(errorContainer!)
    }
    
    func showError(errorMsg: String) {
        errorLabel?.text = errorMsg
        
        if self.errorContainer!.isHidden == true {
            self.errorContainer?.alpha = 0
            self.errorContainer?.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowAnimatedContent, .showHideTransitionViews],
                           animations: {
                            
                self.errorContainer?.alpha = 1
                self.rightViewMode = .always
                self.errorContainer?.frame = CGRect(x: 0, y: self.frame.size.height,
                                                    width: self.errorContainer!.frame.width,
                                                    height: self.errorContainer!.frame.height)
            }) { (success) in
                print(success)
            }
        }
    }
    
    func hideError() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowAnimatedContent, .showHideTransitionViews],
                       animations: {
            self.rightViewMode = .never
            self.errorContainer?.alpha = 0
            self.errorContainer?.frame = CGRect(x: 0, y: self.frame.size.height/2,
                                                width: self.frame.size.width,
                                                height: self.frame.size.height)
        }) { (_) in
            self.errorContainer?.isHidden = true
            self.errorLabel?.text = ""
        }
    }
    
    func updateBorder() {
        let width = CGFloat(0.5)
        if border == nil {
            border = UIView(frame: CGRect(x: 0, y: self.frame.size.height - width,
                                              width:  self.frame.size.width,
                                              height: width))
        }
        
        border!.backgroundColor = bottomBorderColor
        self.addSubview(border!)
    }
    
    func updateIcon() {
        leftIcon = nil
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 25))
        let imageHolder = UIImageView(frame: CGRect(x: 0, y: 2, width: 20, height: 20))
        imageHolder.contentMode = .scaleAspectFit
        imageHolder.image = icon.withRenderingMode(.alwaysTemplate)
        
        containerView.addSubview(imageHolder)
        leftIcon = imageHolder
        self.leftViewMode = .always
        self.leftView = containerView
        self.leftView?.alpha = 0.5
    }
    
    func updateIconColor() {
        if leftIcon != nil {
            leftIcon?.tintColor = iconColor
            self.leftView?.alpha = 0.5
        }
    }
}
