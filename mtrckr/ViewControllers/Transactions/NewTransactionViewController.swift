//
//  NewTransactionViewController.swift
//  mtrckr
//
//  Created by User on 7/8/17.
//

import UIKit
import Eureka
import RealmSwift

protocol NewTransactionViewControllerDelegate: class {
    func shouldSaveTransaction(with name: String, amount: Double, type: TransactionType,
                               date: Date, category: Category?,
                               from sourceAcc: Account, to destAccount: Account)
    func update(transaction: Transaction, withValues name: String, amount: Double,
                type: TransactionType, date: Date, category: Category?,
                from sourceAcc: Account, to destAccount: Account)
}

class NewTransactionViewController: MTFormViewController {

    weak var delegate: NewTransactionViewControllerDelegate?
    var transaction: Transaction?
    var accountsPresenter: AccountsPresenterProtocol?
    var accounts: Results<Account>?

    private let dateTag = "transDate"
    private let nameTag = "transName"
    private let amountTag = "transAmount"
    private let typeTag = "transType"
    private let fromTag = "transFrom"
    private let toTag = "transTo"
    private let catTag = "transCat"
    private let catSectionTag = "transCatSection"

    private var dateRow: DateRow? {
        return self.form.rowBy(tag: dateTag)
    }

    private var nameRow: TextRow? {
        return self.form.rowBy(tag: nameTag)
    }

    private var amountRow: DecimalRow? {
        return self.form.rowBy(tag: amountTag)
    }

    private var typeRow: SegmentedRow<TransactionType>? {
        return self.form.rowBy(tag: typeTag)
    }

    private var fromRow: AccountRow? {
        return self.form.rowBy(tag: fromTag)
    }

    private var toRow: AccountRow? {
        return self.form.rowBy(tag: toTag)
    }

    private var catRow: CategoryRow? {
        return self.form.rowBy(tag: catTag)
    }

    @IBAction func saveBtnPressed(_ sender: Any) {
        let errors = form.validate()
        if errors.isEmpty {
            saveTransaction()
        }
    }

    @IBAction func cancelBtnPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        accountsPresenter = AccountsPresenter(interactor: AccountsInteractor(with: RealmAuthConfig()))
        accounts = accountsPresenter?.accounts()

        if transaction != nil {
            setupTransaction()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "New Transaction"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }

    private func saveTransaction() {
        var toAcc = toRow?.value
        if typeRow?.value! != .transfer {
            toAcc = fromRow!.value!
        }

        if transaction != nil {
            delegate?.update(transaction: transaction!,
                             withValues: nameRow!.value!, amount: amountRow!.value!,
                             type: typeRow!.value!, date: dateRow!.value!,
                             category: catRow?.value, from: fromRow!.value!,
                             to: toAcc!)
        } else {
            delegate?.shouldSaveTransaction(with: nameRow!.value!, amount: amountRow!.value!,
                                            type: typeRow!.value!, date: dateRow!.value!,
                                            category: catRow?.value, from: fromRow!.value!,
                                            to: toAcc!)
        }
        dismiss(animated: true)
    }

    private func setupTransaction() {
        guard let trans = self.transaction else { return }
        typeRow?.value = TransactionType(rawValue: trans.type)
        nameRow?.value = trans.name
        amountRow?.value = trans.amount
        dateRow?.value = trans.transactionDate

        fromRow?.value = trans.fromAccount
        if trans.type == TransactionType.transfer.rawValue {
            toRow?.value = trans.toAccount
        }

        catRow?.value = trans.category
    }

    private func getAccounts(without account: Account?) -> [Account] {
        guard accounts != nil else { return [] }
        guard account != nil else { return Array(accounts!) }
        var accountsArr = Array(accounts!)
        let index = accountsArr.index(of: account!)
        _ = accountsArr.remove(at: index!)
        return accountsArr
    }

    private func setupForm() {
        form
        +++ TextRow { [unowned self] row in
            row.title = NSLocalizedString("Name", comment: "Title for Name field")
            row.placeholder = NSLocalizedString("(Eg.: Lunch, Bus ticket home)",
                                               comment: "Placeholder for name field. Gives examples of possible values")
            row.add(rule: RuleRequired())
            row.tag = self.nameTag
            }

            <<< DateRow { [unowned self] row in
                row.title = NSLocalizedString("Date", comment: "Title for Date field")
                row.value = Date()
                row.tag = self.dateTag
                row.dateFormatter?.timeZone = TimeZone.current
            }

            <<< DecimalRow {[unowned self] row in
                row.title = NSLocalizedString("Amount", comment: "Title for Amount field")
                row.placeholder = NSLocalizedString("0.00", comment: "Default placeholder for amount field")
                row.add(rule: RuleRequired())
                row.tag = self.amountTag
            }

        +++ SegmentedRow<TransactionType> { [unowned self] row in
        row.tag = self.typeTag
        row.options = [TransactionType.expense, TransactionType.income, TransactionType.transfer]
        row.value = TransactionType.expense
        }
        .onChange({ [unowned self] row in
            self.catRow?.updateSelection(forType: row.value!)
        })

            <<< AccountRow(fromTag) { [unowned self] in
                let ruleMustNotMatch = RuleClosure<Account> { rowValue in
                    return (rowValue == self.toRow?.value) ?
                        ValidationError(msg: "Source account and destination account must not be the same") : nil
                }

                $0.tag = self.fromTag
                $0.title = NSLocalizedString("From", comment: "Title for From Account field")
                $0.selectorTitle = NSLocalizedString("My Accounts", comment: "Title for list of accounts")
                $0.noValueDisplayText = NSLocalizedString("Select account",
                                                          comment: "Value of placeholder if no account is selected")
                $0.options = self.getAccounts(without: self.toRow?.value)
                $0.add(rule: RuleRequired())
                $0.add(rule: ruleMustNotMatch)
                $0.validationOptions = .validatesOnDemand
                }

            <<< AccountRow(toTag) { [unowned self] in
                let ruleMustNotMatch = RuleClosure<Account> { rowValue in
                    return (rowValue == self.fromRow?.value) ?
                        ValidationError(msg: "Source account and destination account must not be the same") : nil
                }
                $0.tag = self.toTag
                $0.hidden = Condition.function([self.typeTag], { (_) -> Bool in
                    return self.typeRow?.value != TransactionType.transfer
                })

                $0.title = NSLocalizedString("To", comment: "Title for to account field")
                $0.selectorTitle = NSLocalizedString("My Accounts", comment: "Title for list of accounts")
                $0.noValueDisplayText = NSLocalizedString("Select account",
                                                          comment: "Value of placeholder if no account is selected")
                $0.add(rule: RuleRequired())
                $0.add(rule: ruleMustNotMatch)
                $0.validationOptions = .validatesOnDemand
                $0.options = self.getAccounts(without: self.fromRow?.value)
                }

            +++ Section("Category", { [unowned self] section in
            section.tag = self.catSectionTag
            section.hidden = Condition.function([self.typeTag], { (form) -> Bool in
                return (form.rowBy(tag: self.typeTag) as? SegmentedRow)?.value == TransactionType.transfer
            }) })

            <<< CategoryRow(tag: catTag).cellSetup({ (cell, row) in
                cell.height = { 255 }
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
                row.cellUpdate({ (ce, ro) in
                    if !ro.isValid {
                        ce.backgroundColor = MTColors.subRed
                    } else {
                        ce.backgroundColor = .white
                    }
                })
            })
    }
}
