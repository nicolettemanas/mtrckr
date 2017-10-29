//
//  NewBillViewController.swift
//  mtrckr
//
//  Created by User on 9/5/17.
//

import UIKit
import Eureka

class NewBillViewController: MTFormViewController {
    static let nName = "NewBillViewController"
    
    struct LocalizedStrings {
        static let kEditConfirm = NSLocalizedString("Do you want to edit only this bill or all unpaid bills?",
                                            comment: "Asks whether user edit applies to current bill or all unpaid bills.")
        static let kCancel      = NSLocalizedString("Cancel", comment: "Spiel telling the user to cancel")
        static let kThisBill    = NSLocalizedString("This bill only", comment: "Spiel telling the user to proceed edit of the current bill only.")
        static let kAllBills    = NSLocalizedString("All unpaid bills",
                                                    comment: "Spiel telling the user to proceed edit of all unpaid bills.")
        
        struct Form {
            static let name     = NSLocalizedString("Name", comment: "Title for Name field")
            static let namePH   = NSLocalizedString("(Eg.: Electricity Bill, Phone Bills)",
                                                    comment: "Placeholder for name field. Gives examples of possible values")
            static let amount   = NSLocalizedString("Amount", comment: "Title for Amount field")
            static let amountPH = NSLocalizedString("0.00", comment: "Default placeholder for amount field")
            static let dueDate  = NSLocalizedString("Due date", comment: "Title for the Due date field")
            static let rep      = NSLocalizedString("Repeat schedule", comment: "Title for repeat schedule")
            static let preDate  = NSLocalizedString("Pre-due date reminder", comment: "Title for pre-due date reminder")
            static let postDate = NSLocalizedString("Post-due date reminder", comment: "Title for post-due date reminder")
        }
    }
    
    struct FormTags {
        static let name         = "kBillNameTag"
        static let amount       = "kBillAmountTag"
        static let dueDate      = "kBillDueDateTag"
        static let billRepeat   = "kBillRepeatTag"
        static let pre          = "kBillPreDueDateTag"
        static let post         = "kBillPostDueDateTag"
        static let category     = "kBillCategoryTag"
        static let categorySec  = "kBillCategorySectionTag"
    }
    
    // MARK: - Form fields
    var nameRow: TextRow { return form.rowBy(tag: FormTags.name)! }
    var amountRow: DecimalRow { return form.rowBy(tag: FormTags.amount)! }
    var dueDateRow: DateRow { return form.rowBy(tag: FormTags.dueDate)! }
    var repeatRow: SegmentedRow<String> { return form.rowBy(tag: FormTags.billRepeat)! }
    var preRow: PushRow<String> { return form.rowBy(tag: FormTags.pre)! }
    var postRow: PushRow<String> { return form.rowBy(tag: FormTags.post)! }
    var categoryRow: CategoryRow { return form.rowBy(tag: FormTags.category)! }
    
    // MARK: - NewBillViewControllerProtocol properties
    weak var delegate: NewBillViewControllerDelegate?
    weak var alert: UIAlertController?
    var billEntry: BillEntry?
    var action: MTAlertAction.Type = MTAlertAction.self
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(entry: BillEntry?, delegate del: NewBillViewControllerDelegate) {
        delegate = del
        billEntry = entry
        super.init(nibName: NewBillViewController.nName, bundle: nil)
    }
    
    // MERK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        setupNavBar(title: "New Bill",
                    leftSelector: #selector(didPressCancel),
                    rightSelector: #selector(didPressSave),
                    target: self)
        if billEntry != nil { fillInBillEntry() }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func fillInBillEntry() {
        nameRow.value = billEntry?.customName ?? billEntry?.bill?.name
        amountRow.value = billEntry?.amount
        dueDateRow.value = billEntry?.dueDate
        repeatRow.value = billEntry?.bill?.repeatSchedule
        preRow.value = billEntry?.bill?.preDueReminder
        postRow.value = billEntry?.bill?.postDueReminder
        categoryRow.value = billEntry?.customCategory ?? billEntry?.bill?.category
    }
    
    private func setupForm() {
        setupPrimarySection()
        setupCetegory()
    }
    
    private func setupPrimarySection() {
        form
        +++ TextRow { row in
            row.title = LocalizedStrings.Form.name
            row.placeholder = LocalizedStrings.Form.namePH
            row.add(rule: RuleRequired())
            row.tag = FormTags.name
        }
        
        <<< DecimalRow { row in
            row.title = LocalizedStrings.Form.amount
            row.placeholder = LocalizedStrings.Form.amountPH
            row.add(rule: RuleRequired())
            row.tag = FormTags.amount
        }
        
        <<< DateRow { row in
            row.title = LocalizedStrings.Form.dueDate
            row.value = Date()
            row.tag = FormTags.dueDate
            row.dateFormatter?.timeZone = TimeZone.current
        }
        
        <<< SegmentedRow<String> { row in
            row.tag = FormTags.billRepeat
            row.options = BillRepeatSchedule.allRawValues
            row.value = BillRepeatSchedule.never.rawValue
        }
        
        <<< PushRow<String> { row in
            row.tag = FormTags.pre
            row.title = LocalizedStrings.Form.preDate
            row.value = BillDueReminder.never.rawValue
            row.options = BillDueReminder.allRawValues
        }
        
        <<< PushRow<String> { row in
            row.tag = FormTags.post
            row.title = LocalizedStrings.Form.postDate
            row.value = BillDueReminder.never.rawValue
            row.options = BillDueReminder.allRawValues
        }
    }
    
    private func setupCetegory() {
        form
        +++ Section("Category", { section in
            section.tag = FormTags.categorySec
        })
        
            <<< CategoryRow(tag: FormTags.category).cellSetup({ (cell, row) in
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
