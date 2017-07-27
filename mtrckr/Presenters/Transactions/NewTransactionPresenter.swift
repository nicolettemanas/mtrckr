//
//  NewTransactionPresenter.swift
//  mtrckr
//
//  Created by User on 7/13/17.
//

import UIKit

protocol NewTransactionPresenterProtocol {
    func presentNewTransactionVC(with transaction: Transaction?, presentingVC: UIViewController,
                                 delegate: NewTransactionViewControllerDelegate)
}

class NewTransactionPresenter: NewTransactionPresenterProtocol {
    
    weak var delegate: NewTransactionViewControllerDelegate?
    
    func presentNewTransactionVC(with transaction: Transaction?, presentingVC: UIViewController,
                                 delegate: NewTransactionViewControllerDelegate) {
        let nav = UIStoryboard(name: "Today", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "NewTransactionNavigationController")
        guard let vc = (nav as? UINavigationController)?.topViewController
            as? NewTransactionViewController else {
                return
        }
        
        vc.delegate = delegate
        vc.transaction = transaction
        presentingVC.present(nav, animated: true, completion: nil)
    }
}

protocol DeleteTransactionSheetPresenterProtocol {
    weak var alert: UIAlertController? { get }
    var action: UIAlertAction.Type { get set }
    
    func displayDeleteSheet(toDelete transaction: Transaction, presentingVC: CalendarViewControllerProtocol)
}

class DeleteTransactionSheetPresenter: DeleteTransactionSheetPresenterProtocol {
    
    var action: UIAlertAction.Type = UIAlertAction.self
    weak var alert: UIAlertController?
    
    func displayDeleteSheet(toDelete transaction: Transaction,
                            presentingVC: CalendarViewControllerProtocol) {
        let deleteConfirmation: UIAlertController = UIAlertController(title: nil,
                                                   message: NSLocalizedString("Are you sure you want to delete this transaction? " +
                                                    "This cannot be undone.",
                                                  comment: "A warning that indicates the deletion of the transaction." +
                                                    " Asks for user's confirmation."),
                                                   preferredStyle: .actionSheet)
        
        let cancel = action.makeActionWithTitle(title: NSLocalizedString("Don't delete!", comment: "Spiel telling the user to not delete"),
                                                style: .cancel) { (_) in
                                                    deleteConfirmation.dismiss(animated: true, completion: nil)
        }
        
        let delete = action.makeActionWithTitle(title: NSLocalizedString("Yes, please.",
                                                                         comment: "Spiel telling the user to proceed deletion"),
                                                style: .destructive) { (_) in
                                                    presentingVC.shouldDeleteTransaction(transaction: transaction)
        }
        
        deleteConfirmation.addAction(cancel)
        deleteConfirmation.addAction(delete)
        
        alert = deleteConfirmation
        
        (presentingVC as? UIViewController)?.present(deleteConfirmation, animated: true, completion: nil)
    }
}
