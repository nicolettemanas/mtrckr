//
//  DeleteBillPresenter.swift
//  mtrckr
//
//  Created by User on 8/22/17.
//

import UIKit

protocol DeleteBillPresenterDelegate: class {
    func proceedDeleteEntry(entry: BillEntry, type: ModifyBillType)
    func cancelDeleteEntry(entry: BillEntry)
}

protocol DeleteBillPresenterProtocol {
    var action: UIAlertAction.Type { get set }
    weak var alert: UIAlertController? { get set }
    func presentDeleteSheet(presentingVC: DeleteBillPresenterDelegate, forBillEntry entry: BillEntry)
}

class DeleteBillPresenter: DeleteBillPresenterProtocol {
    var action: UIAlertAction.Type = UIAlertAction.self
    weak var alert: UIAlertController?
    
    func presentDeleteSheet(presentingVC: DeleteBillPresenterDelegate, forBillEntry entry: BillEntry) {
        let deleteConfirmation = UIAlertController(title: nil,
                                                   message: NSLocalizedString("Do you want to delete this bill only or all proceeding bills?" +
                                                    "This cannot be undone.",
                                                  comment: "A warning that indicates the deletion of bills" +
                                                    " cannot be undone. Asks the user whether to delete the current bill" +
                                                    " only or all proceeding bills."),
                                                   preferredStyle: .actionSheet)
        
        let cancel = action.makeActionWithTitle(title: NSLocalizedString("Don't delete!", comment: "Spiel telling the user to not delete"),
                                                style: .cancel) { (_) in
                                                    deleteConfirmation.dismiss(animated: true, completion: nil)
        }
        
        let thisBillOnly = action.makeActionWithTitle(title: NSLocalizedString("This bill only",
                                                                               comment: "Spiel telling the user to proceed" +
                                                                                " deletion of the current bill only."),
                                                style: .destructive) { (_) in
                                                    presentingVC.proceedDeleteEntry(entry: entry, type: .currentBill)
        }
        
        let allBills = action.makeActionWithTitle(title: NSLocalizedString("All proceeding bills",
                                                                               comment: "Spiel telling the user to proceed" +
                                                                                " deletion of all proceeding bills."),
                                                      style: .destructive) { (_) in
                                                        presentingVC.proceedDeleteEntry(entry: entry, type: .allBills)
        }
        
        deleteConfirmation.addAction(cancel)
        deleteConfirmation.addAction(thisBillOnly)
        deleteConfirmation.addAction(allBills)
        
        alert = deleteConfirmation
        
        (presentingVC as? UIViewController)?.present(deleteConfirmation, animated: true, completion: nil)
    }
}
