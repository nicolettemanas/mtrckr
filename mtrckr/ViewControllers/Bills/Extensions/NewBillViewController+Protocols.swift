//
//  NewBillViewController+Protocols.swift
//  mtrckr
//
//  Created by User on 10/13/17.
//

import Foundation
import UIKit

protocol NewBillViewControllerProtocol {
    func saveBill()
    
    var delegate: NewBillViewControllerDelegate? { get set }
    var billEntry: BillEntry? { get set }
    var action: MTAlertAction.Type { get set }
    weak var alert: UIAlertController? { get set }
}

extension NewBillViewController: NewBillViewControllerProtocol {
    
    // MARK: Bill-related methods
    func saveBill() {
        delegate?.saveNewBill(amount: amountRow.value!, name: nameRow.value!,
                              post: postRow.value!, pre: preRow.value!, repeatSchedule: repeatRow.value!,
                              startDate: dueDateRow.value!, category: categoryRow.value!)
        dismiss(animated: true, completion: nil)
    }
}
