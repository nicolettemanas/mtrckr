//
//  PayBillViewController.swift
//  mtrckr
//
//  Created by User on 10/14/17.
//

import UIKit
import Eureka

class PayBillViewController: MTFormViewController {
    static let nName = "PayBillViewController"
    
    var entry: BillEntry?
    weak var delegate: PayBillViewControllerDelegate?
    
    private struct LocalizedStrings {
        static let pay     = NSLocalizedString("Pay amount", comment: "Label for 'Pay' indicating the amount to pay")
        static let accnt   = NSLocalizedString("Using Account", comment: "Label for 'Using account' indicating w/c account to use")
        static let myAcc   = NSLocalizedString("My Accounts", comment: "Title for list of accounts")
        static let slctAcc = NSLocalizedString("Select account", comment: "Value of placeholder if no account is selected")
        static let datePd  = NSLocalizedString("Date Paid", comment: "Title for Date of payment field")
    }
    
    private struct FormTags {
        static let pay     = "kPayTag"
        static let account = "kAccountTag"
        static let date    = "kDateTag"
    }
    
    var payRow: DecimalRow { return form.rowBy(tag: FormTags.pay)! }
    var accountRow: AccountRow { return form.rowBy(tag: FormTags.account)! }
    var dateRow: DateRow { return form.rowBy(tag: FormTags.date)! }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(entry != nil)
    }
    
    init(billEntry: BillEntry, delegate del: PayBillViewControllerDelegate) {
        entry = billEntry
        delegate = del
        super.init(nibName: PayBillViewController.nName, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        setupNavBar(title           : "Pay Bill",
                    leftSelector	: #selector(didPressCancel),
                    rightSelector   : #selector(didPressPayBill),
                    target          : self)
    }

    private func setupForm() {
        form
        +++ DecimalRow { row in
            row.title   = LocalizedStrings.pay
            row.tag     = FormTags.pay
            row.value   = entry?.amount ?? entry?.bill?.amount
            row.add(rule: RuleRequired())
        }
        
        <<< AccountRow(FormTags.account) {
            $0.tag                  = FormTags.account
            $0.title                = LocalizedStrings.accnt
            $0.selectorTitle        = LocalizedStrings.myAcc
            $0.noValueDisplayText   = LocalizedStrings.slctAcc
            $0.options              = []
            $0.add(rule: RuleRequired())
        }
        
        <<< DateRow { row in
            row.dateFormatter?.timeZone = TimeZone.current
            row.title   = LocalizedStrings.datePd
            row.value   = Date()
            row.tag     = FormTags.date
            row.add(rule: RuleRequired())
        }
    }
}
