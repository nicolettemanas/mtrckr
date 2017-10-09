//
//  NewBillViewController.swift
//  mtrckr
//
//  Created by User on 9/5/17.
//

import UIKit
import Eureka

protocol NewBillViewControllerDelegate: class {
    func saveNewBill(amount: Double, name: String, post: String, pre: String,
                     repeatSchedule: String, startDate: Date, category: Category)
    func edit(billEntry: BillEntry, amount: Double, name: String, post: String, pre: String,
              repeatSchedule: String, startDate: Date, category: Category)
    func edit(bill: Bill, amount: Double, name: String, post: String, pre: String,
              repeatSchedule: String, startDate: Date, category: Category, proceedingDate: Date)
}

protocol NewBillViewControllerProtocol {
    func saveBill()
    var delegate: NewBillViewControllerDelegate? { get set }
    var billEntry: BillEntry? { get set }
    var action: MTAlertAction.Type { get set }
    weak var alert: UIAlertController? { get set }
}

class NewBillViewController: MTFormViewController, NewBillViewControllerProtocol {
    struct LocalizedStrings {
        static let kEditConfirm = NSLocalizedString("Do you want to edit only this bill or all proceeding bills?",
                                            comment: "Asks whether user edit applies to current bill or all proceeding bills.")
        static let kCancel      = NSLocalizedString("Cancel", comment: "Spiel telling the user to cancel")
        static let kThisBill    = NSLocalizedString("This bill only", comment: "Spiel telling the user to proceed edit of the current bill only.")
        static let kAllBills    = NSLocalizedString("All proceeding bills",
                                                    comment: "Spiel telling the user to proceed edit of all proceeding bills.")
        
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
    
    // MARK: - Outlets and Actions
    @IBAction func didPressCancel(sender: UIBarButtonItem?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressSave(sender: UIBarButtonItem?) {
        guard form.validate().isEmpty else { return }
        guard let entry = billEntry else {
            saveBill()
            return
        }
        presentEditBillSheet(billEntry: entry)
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
    var action: MTAlertAction.Type
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        action = MTAlertAction.self
        super.init(coder: aDecoder)
    }
    
    static func initWith(delegate: NewBillViewControllerDelegate) -> NewBillViewController {
        let sboard = UIStoryboard(name: "Bills", bundle: Bundle.main)
        guard let vc: NewBillViewController = sboard
            .instantiateViewController(withIdentifier: "NewBillViewController")
                as? NewBillViewController else { fatalError("Cannot convert to NewBillViewController") }
        vc.delegate = delegate
        vc.action = MTAlertAction.self
        return vc
    }
    
    // MERK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        if billEntry != nil { fillInBillEntry() }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Bill-related methods
    func saveBill() {
        delegate?.saveNewBill(amount: amountRow.value!, name: nameRow.value!,
                              post: postRow.value!, pre: preRow.value!, repeatSchedule: repeatRow.value!,
                              startDate: dueDateRow.value!, category: categoryRow.value!)
        dismiss(animated: true, completion: nil)
    }
    
    private func presentEditBillSheet(billEntry entry: BillEntry) {
        let editOption = UIAlertController(title: nil, message: nil,
                                           preferredStyle: .actionSheet)
        editOption.title = nil
        editOption.message = LocalizedStrings.kEditConfirm

        let cancel = action.makeActionWithTitle(title: LocalizedStrings.kCancel,
                                                style: .cancel) { (_) in
            editOption.dismiss(animated: true, completion: nil)
        }

        let thisBillOnly = action.makeActionWithTitle(title: LocalizedStrings.kThisBill,
                                                      style: .destructive) { [unowned self] (_) in
            self.delegate?.edit(billEntry: self.billEntry!, amount: self.amountRow.value!, name: self.nameRow.value!,
                                post: self.postRow.value!, pre: self.preRow.value!, repeatSchedule: self.repeatRow.value!,
                                startDate: self.dueDateRow.value!, category: self.categoryRow.value!)
            self.dismiss(animated: true, completion: nil)
        }
        let allBills = action.makeActionWithTitle(title: LocalizedStrings.kAllBills,
                                                  style: .destructive) { [unowned self] (_) in
            self.delegate?.edit(bill: self.billEntry!.bill!, amount: self.amountRow.value!, name: self.nameRow.value!,
                                post: self.postRow.value!, pre: self.preRow.value!, repeatSchedule: self.repeatRow.value!,
                                startDate: self.dueDateRow.value!, category: self.categoryRow.value!, proceedingDate: Date())
            self.dismiss(animated: true, completion: nil)
        }

        editOption.addAction(cancel)
        editOption.addAction(thisBillOnly)
        editOption.addAction(allBills)

        alert = editOption
        present(editOption, animated: true, completion: nil)
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
