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
