//
//  NewTransactionViewController.swift
//  mtrckr
//
//  Created by User on 7/8/17.
//

import UIKit
import Eureka

class NewTransactionViewController: FormViewController {
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupDefaultRows() {
        let requiredRule = RuleClosure<String> { rowValue in
            if rowValue == nil || rowValue!.isEmpty {
                return ValidationError(msg: NSLocalizedString("You can't leave this empty!",
                                                              comment: "Text informing the user that the field is " +
                    "required and cannot be left empty"))
            }
            return nil
        }
        
        TextRow.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.titleLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.titleLabel?.textColor = MTColors.mainText
            cell.textField.font = UIFont.mySystemFont(ofSize: 13)
            cell.textField.textColor = MTColors.subText
            row.add(rule: requiredRule)
        }
        
        TextRow.defaultOnCellHighlightChanged = { cell, _ in
            cell.titleLabel?.textColor = MTColors.mainBlue
        }
        
        DateRow.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.textLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.textLabel?.textColor = MTColors.mainText
        }
        
        DateRow.defaultOnCellHighlightChanged = {cell, _ in
            cell.textLabel?.textColor = MTColors.mainBlue
        }
    }
    
    private func setupForm() {
        setupDefaultRows()
        form
        +++ TextRow {
            $0.title = "Name"
            $0.placeholder = "(Eg.: Lunch, Bus ticket home)"
            }
            
            <<< DateRow {
                $0.title = "Date"
                $0.value = Date()
            }
            
        +++ SegmentedRow<TransactionType> {
            $0.tag = "Transaction type"
            $0.options = [TransactionType.expense, TransactionType.income, TransactionType.transfer]
            $0.value = TransactionType.expense
            }
            .onChange({ (row) in
                (self.form.rowBy(tag: "Categories") as? CategoryRow)?.updateSelection(forType: row.value!)
            })
            
            <<< PushRow<String>("From Account") {
                let accounts = ["BPI Savings Account", "Security Bank Payroll", "Cash", "Investment"]
                $0.title = "From"
                $0.selectorTitle = "My Accounts"
                $0.noValueDisplayText = "Select account"
                $0.options = accounts
                }.cellUpdate({ (cell, _) in
                    cell.height = { 55 }
                    cell.textLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
                    cell.textLabel?.textColor = MTColors.mainText
                })
            
            <<< PushRow<String>("To Account") {
                $0.hidden = Condition.function(["Transaction type"], { (form) -> Bool in
                    return (form.rowBy(tag: "Transaction type") as? SegmentedRow)?.value != TransactionType.transfer
                })
                
                let accounts = ["BPI Savings Account", "Security Bank Payroll", "Cash", "Investment"]
                $0.title = "To"
                $0.selectorTitle = "My Accounts"
                $0.noValueDisplayText = "Select account"
                $0.options = accounts
                }.cellUpdate({ (cell, _) in
                    cell.height = { 55 }
                    cell.textLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
                    cell.textLabel?.textColor = MTColors.mainText
                })
            
        +++ Section("Category", { (section) in
            section.tag = "Category"
            section.hidden = Condition.function(["Transaction type"], { (form) -> Bool in
                return (form.rowBy(tag: "Transaction type") as? SegmentedRow)?.value == TransactionType.transfer
            }) })
            
            <<< CategoryRow(tag: "Categories").cellSetup({ (cell, _) in
                cell.height = { 255 }
                cell.selectItem(at: IndexPath(item: 0, section: 0))
            })
    }
}
