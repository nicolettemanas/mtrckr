//
//  NewBillViewController+Protocols.swift
//  mtrckr
//
//  Created by User on 10/13/17.
//

import Foundation
import UIKit

protocol NewBillViewControllerProtocol {
    func didPressCancel()
    func didPressSave()

    var delegate: NewBillViewControllerDelegate? { get set }
    var billEntry: BillEntry? { get set }
    var action: MTAlertAction.Type { get set }
    weak var alert: UIAlertController? { get set }
}

extension NewBillViewController: NewBillViewControllerProtocol {

    // MARK: Bill-related methods
    func saveBill() {
        delegate?.saveNewBill(amount    : amountRow.value!,
                              name      : nameRow.value!,
                              post      : postRow.value!,
                              pre       : preRow.value!,
                              repeat    : repeatRow.value!,
                              startDate : dueDateRow.value!,
                              category  : categoryRow.value!)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Actions
    @objc func didPressCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func didPressSave() {
        guard form.validate().isEmpty else { return }
        guard let entry = billEntry else {
            saveBill()
            return
        }
        presentEditBillSheet(billEntry: entry)
    }

    func presentEditBillSheet(billEntry entry: BillEntry) {
        let editOption = UIAlertController(title: nil, message: nil,
                                           preferredStyle: .actionSheet)
        editOption.title = nil
        editOption.message = LocalizedStrings.kEditConfirm

        let cancel = action
            .makeActionWithTitle(title: LocalizedStrings.kCancel,
                                 style: .cancel) { (_) in
                editOption.dismiss(animated: true, completion: nil)
        }

        let thisBillOnly = action
            .makeActionWithTitle(title: LocalizedStrings.kThisBill,
                                 style: .destructive) { [unowned self] (_) in

                self.delegate?.edit(billEntry       : self.billEntry!,
                                    amount          : self.amountRow.value!,
                                    name            : self.nameRow.value!,
                                    post            : self.postRow.value!,
                                    pre             : self.preRow.value!,
                                    repeatSchedule  : self.repeatRow.value!,
                                    startDate       : self.dueDateRow.value!,
                                    category        : self.categoryRow.value!)

                self.dismiss(animated: true, completion: nil)
        }
        let allBills = action
            .makeActionWithTitle(title: LocalizedStrings.kAllBills,
                                 style: .destructive) { [unowned self] (_) in
                assert(self.billEntry?.bill?.active == true)
                self.delegate?.edit(bill: self.billEntry!.bill!,
                                    amount: self.amountRow.value!,
                                    name: self.nameRow.value!,
                                    post: self.postRow.value!,
                                    pre: self.preRow.value!,
                                    repeatSchedule: self.repeatRow.value!,
                                    startDate: self.dueDateRow.value!,
                                    category: self.categoryRow.value!)
                self.dismiss(animated: true, completion: nil)
        }

        editOption.addAction(cancel)
        editOption.addAction(thisBillOnly)
        editOption.addAction(allBills)

        alert = editOption
        present(editOption, animated: true, completion: nil)
    }
}
