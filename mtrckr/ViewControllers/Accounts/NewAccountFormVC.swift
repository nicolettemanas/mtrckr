//
//  NewAccountFormVC.swift
//  mtrckr
//
//  Created by User on 11/6/17.
//

import UIKit
import Eureka

protocol NewAccountViewControllerDelegate: class {
    func shouldCreateAccount(withId: String?, name: String, type: AccountType,
                             initBalance: Double, dateOpened: Date,
                             color: UIColor)
}

class NewAccountFormVC: MTFormViewController {
    static let nName = "NewAccountViewController"

    struct LocalizedStrings {
        static let title            = NSLocalizedString("New Account",
                                    comment: "Title of the page when creating a new account")
        struct Form {
            static let name         = NSLocalizedString("Name", comment: "Title for Name field")
            static let namePH       = NSLocalizedString("(Eg.: Cash in hand)",
                                    comment: "Placeholder for name field. Gives examples of possible values")
            static let balance      = NSLocalizedString("Starting balance", comment: "Title for Balance field")
            static let balancePH    = NSLocalizedString("0.00", comment: "Default placeholder for balance field")

            static let date         = NSLocalizedString("Date opened", comment: "Title for Date opened field")
            static let datePH       = NSLocalizedString("Today", comment: "Default placeholder for date opened field")
            static let type         = NSLocalizedString("Account type", comment: "Title for selecting an Account Type")
            static let color        = NSLocalizedString("Account Color",
                                    comment: "Title for selecting a color for an account")
        }
    }

    struct FormTags {
        static let name     = "kAccountNameTag"
        static let balance  = "kAccountBalanceTag"
        static let date     = "kAccountDateTag"
        static let type     = "kAccountTypeTag"
        static let color    = "kAccountColorTag"
    }

    // MARK: - Form fields
    var nameRow: TextRow { return form.rowBy(tag: FormTags.name)! }
    var typeRow: AccountTypeRow { return form.rowBy(tag: FormTags.type)! }
    var balanceRow: DecimalRow { return form.rowBy(tag: FormTags.balance)! }
    var dateRow: DateRow { return form.rowBy(tag: FormTags.date)! }
    var colorsRow: ColorRow { return form.rowBy(tag: FormTags.color)! }

    weak var delegate: NewAccountViewControllerDelegate?
    var account: Account?
    var accountTypeDataSource: AccountTypeCollectionDataSource?

    // MARK: - Initializer
    init(account anAccount: Account?,
         delegate del: NewAccountViewControllerDelegate?,
         accntTypeDatasource: AccountTypeCollectionDataSource) {

        delegate = del
        account = anAccount
        accountTypeDataSource = accntTypeDatasource
        super.init(nibName: NewAccountFormVC.nName, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar(title: LocalizedStrings.title,
                    leftSelector: #selector(cancel),
                    rightSelector: #selector(save),
                    target: self)
        setupForm()
        if account != nil { fillInAccount() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = nameRow.cell.cellBecomeFirstResponder(withDirection: .up)
    }

    @objc func cancel() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    @objc func save() {
        view.endEditing(true)
        if isValid() == true {
            returnFields()
            dismiss(animated: true, completion: nil)
        }
    }

    private func isValid() -> Bool {
        guard form.validate().isEmpty else { return false}
        return true
    }

    private func fillInAccount() {
        guard let accnt = account else { return }
        nameRow.value = accnt.name
        typeRow.value = accnt.type
        balanceRow.value = accnt.initialAmount
        dateRow.value = accnt.dateOpened
        colorsRow.value = UIColor(accnt.color)
    }

    private func returnFields() {
        delegate?
            .shouldCreateAccount(withId         : account?.id,
                                 name           : nameRow.value!,
                                 type           : typeRow.value!,
                                 initBalance    : balanceRow.value!,
                                 dateOpened     : dateRow.value!,
                                 color          : colorsRow.value!)
    }

    private func setupForm() {
        form
        +++ TextRow { row in
            row.title = LocalizedStrings.Form.name
            row.placeholder = LocalizedStrings.Form.namePH
            row.add(rule: RuleRequired())
            row.tag = FormTags.name
        }

        <<< AccountTypeRow(tag: FormTags.type).cellSetup({ (cell, row) in
            cell.height = { 90 }
            row.title = LocalizedStrings.Form.type
            row.validationOptions = .validatesOnDemand
            row.add(rule: RuleRequired())
            row.cellUpdate({ (ce, ro) in
                ce.backgroundColor = ro.isValid ? .white : MTColors.subRed
            })
        })

        <<< DecimalRow { row in
            row.title = LocalizedStrings.Form.balance
            row.placeholder = LocalizedStrings.Form.balancePH
            row.add(rule: RuleRequired())
            row.tag = FormTags.balance
        }

        <<< DateRow { row in
            row.title = LocalizedStrings.Form.date
            row.value = Date()
            row.tag = FormTags.date
            row.dateFormatter?.timeZone = TimeZone.current
        }

        <<< ColorRow(tag: FormTags.color).cellSetup({ (cell, row) in
            cell.height = { 90 }
            row.title = LocalizedStrings.Form.color
            row.validationOptions = .validatesOnDemand
            row.add(rule: RuleRequired())
            row.cellUpdate({ (ce, ro) in
                ce.backgroundColor = ro.isValid ? .white : MTColors.subRed
            })
        })
    }
}
