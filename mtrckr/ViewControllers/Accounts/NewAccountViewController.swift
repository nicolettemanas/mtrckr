//
//  NewAccountViewController.swift
//  mtrckr
//
//  Created by User on 6/28/17.
//

import UIKit
import DateToolsSwift
import UIColor_Hex_Swift

protocol NewAccountViewControllerDelegate: class {
    func shouldCreateAccount(withId: String?, name: String, type: AccountType,
                             initBalance: Double, dateOpened: Date,
                             color: UIColor)
}

class NewAccountViewController: MTViewController, UICollectionViewDelegate,
AccountTypeCollectionDelegate, ColorsCollectionDelegate {
    
    // MARK: - IBOutlets and IBActions
    @IBOutlet weak var nameTxtField: MTTextField!
    @IBOutlet weak var startingBalanceTxtField: MTTextField!
    @IBOutlet weak var dateOpenedTxtField: MTTextField!
    
    @IBOutlet weak var typeCollectionView: UICollectionView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    @IBOutlet weak var okBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    @IBOutlet weak var accountsScrollView: UIScrollView!
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okBtnPressed(_ sender: Any) {
        if isValid() {
            view.endEditing(true)
            dismiss(animated: true, completion: {
                self.returnFields()
            })
        }
    }
    
    // MARK: - Properties
    weak var delegate: NewAccountViewControllerDelegate?
    
    var selectedType: AccountType?
    var selectedColor: UIColor?
    
    var accTypeDataSource: AccountTypeCollectionDataSource?
    var colorDataSource: ColorsCollectionDataSource?
    
    var account: Account?
    
    override func viewDidLoad() {
        setupUIFields()
        if account != nil {
            autoFillAccount()
        }
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTxtField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UI setup methods
    private func autoFillAccount() {
        nameTxtField.text = account?.name
        startingBalanceTxtField.text = "\(account!.initialAmount)"
        dateOpenedTxtField.datePicker?.date = account!.dateOpened
        dateOpenedTxtField.text = account!.dateOpened.format(with: "MMM dd, yyyy")
        
        selectedType = account!.type
        selectedColor = UIColor(account!.color)
        
        accTypeDataSource?.select(type: selectedType!)
        colorDataSource?.select(color: selectedColor!)
    }
    
    private func setupUIFields() {
        scrollView = accountsScrollView
        
        nameTxtField.delegate = self
        startingBalanceTxtField.delegate = self
        dateOpenedTxtField.delegate = self
        
        accTypeDataSource = AccountTypeCollectionDataSource(with: RealmAuthConfig(),
                                                            collectionView: typeCollectionView)
        colorDataSource = ColorsCollectionDataSource(with: RealmAuthConfig(),
                                                     collectionView: colorCollectionView)
        
        accTypeDataSource?.delegate = self
        colorDataSource?.delegate = self
        
        typeCollectionView.dataSource = accTypeDataSource
        typeCollectionView.delegate = accTypeDataSource
        colorCollectionView.dataSource = colorDataSource
        colorCollectionView.delegate = colorDataSource
        
        dateOpenedTxtField.setInputType(type: .date)
        
        accTypeDataSource?.selectDefault()
        colorDataSource?.selectDefault()
        
        okBtn.tintColor = MTColors.mainBlue
        cancelBtn.tintColor = MTColors.mainRed
    }
    
    func isValid() -> Bool {
        if startingBalanceTxtField.text == "" || startingBalanceTxtField.text == nil {
            startingBalanceTxtField.text = "0.00"
        }
        
        if dateOpenedTxtField.text == "" || dateOpenedTxtField.text == nil {
            dateOpenedTxtField.text = Date().format(with: "MMM dd, yyyy")
        }
        
        if selectedType == nil {
            accTypeDataSource?.selectDefault()
        }
        
        if selectedColor == nil {
            colorDataSource?.selectDefault()
        }
        
        if nameTxtField.text == "" || nameTxtField.text == nil {
            nameTxtField.showError(errorMsg: NSLocalizedString("You can't leave this empty",
                                                               comment: "Indicates that the field is required"))
            return false
        }
        
        return true
    }
    
    private func returnFields() {
        let date = Date(dateString: dateOpenedTxtField.text!,
                        format: "MMM dd, yyyy",
                        timeZone: TimeZone.current)
        delegate?.shouldCreateAccount(withId: account?.id,
                                      name: nameTxtField.text!,
                                      type: selectedType!,
                                      initBalance: Double(startingBalanceTxtField.text!)!,
                                      dateOpened: date,
                                      color: selectedColor!)
    }
    
    // MARK: - UITextFieldDelegate methods
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if nameTxtField == textField {
            let txt = (nameTxtField.text! as NSString).replacingCharacters(in: range, with: string)
            if txt.characters.count > 0 {
                nameTxtField.hideError()
            }
        }
        
        return true
    }
    
    // MARK: - AccountTypeCollectionDelegate and ColorsCollectionDelegate methods
    func didSelect(accountType type: AccountType) {
        selectedType = type
    }
    
    func didSelect(color: UIColor) {
        selectedColor = color
    }
    
}
