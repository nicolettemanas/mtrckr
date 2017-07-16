//
//  AccountsSelectionViewController.swift
//  mtrckr
//
//  Created by User on 7/13/17.
//

import UIKit
import Eureka

class AccountsSelectionViewController: SelectorViewController<Account> {
    
    var accounts: [Account] = []
    var presenter: AccountsPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back-tab")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back-tab")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
        presenter = AccountsPresenter(interactor: AccountsInteractor(with: RealmAuthConfig()))
        guard let accnts = presenter?.accounts() else { return }
        accounts = Array(accnts)
        
        for accnt in accounts {
            form.last! <<< ListCheckRow<Account>(accnt.name) { ro in
                ro.title = accnt.name
                ro.selectableValue = accnt
                ro.value = self.row.value == accnt ? accnt : nil
            }
        }
    }
}

final class AccountsSelectorRow: SelectorRow<PushSelectorCell<Account>, AccountsSelectionViewController>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = PresentationMode.show(controllerProvider:
            ControllerProvider.callback(builder: { () -> AccountsSelectionViewController in
            return AccountsSelectionViewController { _ in }
        }), onDismiss: { (vc) in
                vc.navigationController?.popViewController(animated: true)
        })
        
        cellSetup { (cell, _) in
            cell.height = { 55 }
            cell.textLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.textLabel?.textColor = MTColors.mainText
        }
        
        cellUpdate { (cell, ro) in
            if ro.value != nil {
                cell.detailTextLabel?.text = ro.value?.name
            }
        }
        
        onRowValidationChanged { (cell, ro) in
            if !ro.isValid {
                cell.textLabel?.textColor = MTColors.mainRed
                cell.backgroundColor = MTColors.subRed
            } else {
                cell.backgroundColor = .white
            }
        }
    }
}
