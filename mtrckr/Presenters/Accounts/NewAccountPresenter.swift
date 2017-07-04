//
//  NewAccountPresenter.swift
//  mtrckr
//
//  Created by User on 7/4/17.
//

import UIKit

protocol NewAccountPresenterProtocol {
    func presentNewAccountVC(with account: Account?, presentingVC: UIViewController,
                             delegate: NewAccountViewControllerDelegate)
}

class NewAccountPresenter: NewAccountPresenterProtocol {
    func presentNewAccountVC(with account: Account?, presentingVC: UIViewController,
                             delegate: NewAccountViewControllerDelegate) {
        let nav = UIStoryboard(name: "Accounts", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "NewAccountNavigationController")
        guard let vc = (nav as? UINavigationController)?.topViewController
            as? NewAccountViewController else {
                return
        }
        
        vc.delegate = delegate
        vc.account = account
        presentingVC.present(nav, animated: true, completion: nil)
    }
}

protocol DeleteSheetPresenterProtocol {
    weak var alert: UIAlertController? { get }
    var action: UIAlertAction.Type { get set }
    
    func displayDeleteSheet(toDelete indexPath: IndexPath, presentingVC: MTAccountsTableViewController)
}

class DeleteSheetPresenter: DeleteSheetPresenterProtocol {
    var action: UIAlertAction.Type = UIAlertAction.self
    weak var alert: UIAlertController?
    
    func displayDeleteSheet(toDelete indexPath: IndexPath, presentingVC: MTAccountsTableViewController) {
        let deleteConfirmation = UIAlertController(title: nil,
                                                   message: NSLocalizedString("Are you sure you want to delete this account? " +
                                                    "Deleting an account deletes all associated transactions. " +
                                                    "This cannot be undone.", comment: "A warning that indicates the deletion of transactions under" +
                                                    " the account to be deleted. Asks for user's confirmation."),
                                                   preferredStyle: .actionSheet)
        
        let cancel = action.makeActionWithTitle(title: NSLocalizedString("Don't delete!", comment: "Spiel telling the user to not delete"),
                                                       style: .cancel) { (_) in
            deleteConfirmation.dismiss(animated: true, completion: nil)
        }
        
        let delete = action.makeActionWithTitle(title: NSLocalizedString("Yes, please.",
                                                                                comment: "Spiel telling the user to proceed deletion"),
                                   style: .destructive) { (_) in
            presentingVC.deleteAccount(atIndex: indexPath)
        }
        
        deleteConfirmation.addAction(cancel)
        deleteConfirmation.addAction(delete)
        
        alert = deleteConfirmation
        
        presentingVC.present(deleteConfirmation, animated: true, completion: nil)
    }
}

// source: http://swiftandpainless.com/correction-on-testing-uialertcontroller/
extension UIAlertAction {
    class func makeActionWithTitle(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?) -> UIAlertAction {
        return UIAlertAction(title: title, style: style, handler: handler)
    }
}
