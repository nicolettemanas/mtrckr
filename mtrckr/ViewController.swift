//
//  ViewController.swift
//  mtrckr
//
//  Created by User on 4/5/17.
//
//

import UIKit
import Realm
import RealmSwift

class ViewController: UIViewController, RealmAuthPresenterOutput {

    override func viewDidLoad() {
        super.viewDidLoad()

        let interactor = RealmAuthInteractor(config: RealmAuthConfig())
        let presenter = RealmAuthPresenter(interactor: interactor,
                                        encrypter: EncryptionInteractor(),
                                        output: self)
        interactor.output = presenter

        if SyncUser.current != nil {
            interactor.logout()
        }
        
        print(RealmHolder.sharedInstance.userRealm?.objects(Currency.self) ?? "No currencies")
        print(RealmHolder.sharedInstance.userRealm?.objects(AccountType.self) ?? "No currencies")
        print(RealmHolder.sharedInstance.userRealm?.objects(Category.self) ?? "No currencies")
        
        presenter.login(withEmail: "user9@gmail.com", withPassword: "user9")
//        presenter.register(withEmail: "user10@gmail.com", withPassword: "user10", withName: "User10")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - RealmAuthPresenterOutput methods
    func showSuccessfulLogin(ofUser user: RLMSyncUser) {
        
    }
    
    func showSuccessfulRegistration(ofUser user: RLMSyncUser) {
    
    }
    
    func showSuccesfulLogout() {
        
    }

    func showFailedAuth(withAlert alert: UIAlertController?) {
        
    }
}
