//
//  MTTextField.swift
//  mtrckr
//
//  Created by User on 6/2/17.
//
//

import UIKit
import DateToolsSwift

/// Collection of textfield types. It determines the
/// input view of the textfield
///
/// - `.text`: If the textfield only needs a text input
/// - `.date`: If the textfield needs a date input
/// - `.numeric`: If the textfield needs numeric input
/// - `.decimal`: If the textfield needs decimal input
enum MTTextFieldInputType {
    case text, date, numeric, decimal
}

/// Base class for a UITextField
class MTTextField: UITextField {

    /// The UIDatePicker input view used if type is `.date`
    var datePicker: UIDatePicker?

    // MARK: - Properties
    /// UIColor value of the bottom border to be rendered
    @IBInspectable var bottomBorderColor: UIColor = MTColors.mainBlue { didSet { updateBorder() }}

    /// The UIImage icon to be displaued at the left view iof the text field
    @IBInspectable var icon: UIImage = MTTextField.getDefaultImage() { didSet { updateIcon() }}

    /// The masked color of the icon
    @IBInspectable var iconColor: UIColor = MTColors.mainBg { didSet { updateIconColor() }}

    private var leftIcon: UIImageView?
    private var warningIcon: UIImageView?

    private var errorLabel: UILabel?
    private var errorContainer: UIView?
    private var border: UIView?

    // MARK: - Methods
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

    private func setupUI() {
        self.textColor = MTColors.mainText
        if let p = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: p,
                                                            attributes: [NSAttributedStringKey.foregroundColor:
                                                                MTColors.placeholderText])
        }

        let x = (textAlignment == .right) == true ? 35-20 : 0
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 25))
        let imageHolder = UIImageView(frame: CGRect(x: x, y: 2, width: 20, height: 20))
        imageHolder.contentMode = .scaleAspectFit
        imageHolder.image = UIImage(named: "warning")?.withRenderingMode(.alwaysTemplate)
        imageHolder.tintColor = MTColors.mainRed

        containerView.addSubview(imageHolder)
        warningIcon = imageHolder
        self.rightViewMode = .never
        self.rightView = containerView
        self.rightView?.alpha = 0.8

        errorContainer = UIView(frame: CGRect(x: 0, y: self.frame.size.height/2,
                                              width: self.frame.size.width,
                                              height: 15))
        errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 15))
        errorLabel?.textColor = MTColors.mainRed
        errorLabel?.font = UIFont.systemFont(ofSize: 12)
        errorContainer?.isHidden = true
        errorLabel?.textAlignment = textAlignment

        errorContainer?.addSubview(errorLabel!)
        self.addSubview(errorContainer!)
    }

    /// Setups the input type and adds accessory views
    ///
    /// - Parameter type: The type of the input in format `MTTextFieldInputType`
    func setInputType(type: MTTextFieldInputType) {
        switch type {
        case .text:
            keyboardType = UIKeyboardType.alphabet
        case .date:
            setupDateInputView()
        case .decimal:
            keyboardType = UIKeyboardType.decimalPad
        case .numeric:
            keyboardType = UIKeyboardType.numberPad
        }
    }

    /// Displays an error message at the bottom of the textfield
    ///
    /// - Parameter errorMsg: Message to be displayed
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

    /// Hides the error message of the textfield if applicable
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

    private func updateBorder() {
        let width = CGFloat(0.5)
        if border == nil {
            border = UIView(frame: CGRect(x: 0, y: self.frame.size.height - width,
                                              width:  self.frame.size.width,
                                              height: width))
        }

        border!.backgroundColor = bottomBorderColor
        self.addSubview(border!)
    }

    private func updateIcon() {
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

    private func updateIconColor() {
        if leftIcon != nil {
            leftIcon?.tintColor = iconColor
            self.leftView?.alpha = 0.5
        }
    }

    private func setupDateInputView() {
        datePicker = UIDatePicker()

        datePicker?.datePickerMode = .date
        datePicker?.maximumDate = Date()
        datePicker?.setDate(Date(), animated: false)

        inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = MTColors.mainBlue
        toolbar.sizeToFit()

        let doneBtn = UIBarButtonItem(image: UIImage(named: "check-tab"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(selectAndDismiss))
        let cancelBtn = UIBarButtonItem(image: UIImage(named: "x-tab"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(dismissInput))

        doneBtn.tintColor = MTColors.mainBlue
        cancelBtn.tintColor = MTColors.mainRed

        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: #selector(dismissInput))

        toolbar.setItems([cancelBtn, spaceButton, doneBtn], animated: false)
        toolbar.isUserInteractionEnabled = true
        inputAccessoryView = toolbar
    }

    @objc private func selectAndDismiss() {
        text = datePicker?.date.format(with: "MMM dd, yyyy")
        resignFirstResponder()
    }

    @objc private func dismissInput() {
        resignFirstResponder()
    }
}
