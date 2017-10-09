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

/// Class responsible for presenting `NewTransactionViewController`
class NewTransactionPresenter: NewTransactionPresenterProtocol {
    
    weak var delegate: NewTransactionViewControllerDelegate?
    
    /// Presents the `NewTransactionViewController`
    ///
    /// - Parameters:
    ///   - transaction: The `Transaction` to be edited if available
    ///   - presentingVC: The presenting `ViewController`
    ///   - delegate: The delegate of `NewTransactionViewController`
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

/// Protocol for the delegate methods of `DeleteTransactionSheetPresenter`
protocol DeleteTransactionSheetPresenterDelegate: class {
    
    /// Triggered when a `Transaction` is confirmed to be deleted
    ///
    /// - Parameter transaction: The `Transaction` to be deleted
    func shouldDeleteTransaction(transaction: Transaction)
}

protocol DeleteTransactionSheetPresenterProtocol {
    weak var alert: UIAlertController? { get }
    var action: MTAlertAction.Type { get set }
    
    func displayDeleteSheet(toDelete transaction: Transaction, presentingVC: DeleteTransactionSheetPresenterDelegate)
}

/// Class responsible for presenting the Delete `UIAlertController` for confirmation
class DeleteTransactionSheetPresenter: DeleteTransactionSheetPresenterProtocol {
    
    var action: MTAlertAction.Type = MTAlertAction.self
    weak var alert: UIAlertController?
    
    /// Displays a `UIAlertController` confirming the deletion of a `Transaction`
    ///
    /// - Parameters:
    ///   - transaction: The `Transaction` to be deleted
    ///   - presentingVC: The presenting `ViewController`
    func displayDeleteSheet(toDelete transaction: Transaction,
                            presentingVC: DeleteTransactionSheetPresenterDelegate) {
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
