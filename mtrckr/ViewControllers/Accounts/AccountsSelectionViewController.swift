//
//  AccountsSelectionViewController.swift
//  mtrckr
//
//  Created by User on 7/13/17.
//

import UIKit
import Eureka

class AccountsSelectionViewController: FormViewController, TypedRowControllerType {
    
    var onDismissCallback: ((UIViewController) -> Void)?
    var row: RowOf<Account>!
    
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

        form +++
            Section()
            
        for accnt in accounts {
            form.last! <<< CheckRow() {
                $0.title = accnt.name
                $0.value = self.row.value == accnt
                }.onCellSelection({ [unowned self] (_, _)  in
                    self.row.value = accnt
                    self.onDismissCallback?(self)
                })
        }
        
//        for accnt in accounts {
//            form.last! <<< ListCheckRow<Account>(accnt.name) { ro in
//                ro.title = accnt.name
//                ro.selectableValue = accnt
//                ro.value = self.row.value == accnt ? accnt : nil
//            }
//        }
    }
}

//final class AccountsSelectorRow: SelectorRow<PushSelectorCell<Account>, AccountsSelectionViewController>, RowType {
//    required init(tag: String?) {
//        super.init(tag: tag)
//        presentationMode = PresentationMode.show(controllerProvider:
//            ControllerProvider.callback(builder: { () -> AccountsSelectionViewController in
//            return AccountsSelectionViewController { _ in }
//        }), onDismiss: { (vc) in
//                vc.navigationController?.popViewController(animated: true)
//        })
//
//        cellSetup { (cell, _) in
//            cell.height = { 55 }
//            cell.textLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
//            cell.textLabel?.textColor = MTColors.mainText
//        }
//
//        cellUpdate { (cell, ro) in
//            if ro.value != nil {
//                cell.detailTextLabel?.text = ro.value?.name
//            }
//        }
//
//        onRowValidationChanged { (cell, ro) in
//            if !ro.isValid {
//                cell.textLabel?.textColor = MTColors.mainRed
//                cell.backgroundColor = MTColors.subRed
//            } else {
//                cell.backgroundColor = .white
//            }
//        }
//    }
//}

final class AccountRow: OptionsRow<PushSelectorCell<Account>>, PresenterRowType, RowType {
    
    //    public typealias PresenterRow = FolderViewController
    
    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<AccountsSelectionViewController>?
    
    /// Will be called before the presentation occurs.
    open var onPresentCallback: ((FormViewController, AccountsSelectionViewController) -> Void)?

    required public init(tag: String?) {
        super.init(tag: tag)
        let provider = ControllerProvider<AccountsSelectionViewController>
            .callback { AccountsSelectionViewController() }
        
        presentationMode = PresentationMode.show(controllerProvider: provider, onDismiss: { (vc) in
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
    
    /**
     Extends `didSelect` method
     */
    open override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? AccountsSelectionViewController else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
        rowVC.row.value = value
    }
}
