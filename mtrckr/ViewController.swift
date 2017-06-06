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

//        InitialRealmGenerator.generateInitRealm { (_) in
//            let interactor = RealmAuthInteractor(config: RealmAuthConfig())
//            let presenter = RealmAuthPresenter(interactor: interactor,
//                                               encrypter: EncryptionInteractor(),
//                                               output: self)
//            interactor.output = presenter
//            
//            if SyncUser.current != nil {
//                interactor.logout()
//            }
        
            // #####
            // Offline first, register to sync
            // #####
//            let realm = RealmHolder.sharedInstance.userRealm
//            let cashAccountType = AccountType.with(key: 218, inRealm: realm!)
//            let account = Account(value: ["id": "accnt3",
//                                          "name": "My Cash",
//                                          "type": cashAccountType!,
//                                          "initialAmount": 10.0,
//                                          "currentAmount": 20.0,
//                                          "totalExpenses": 100.0,
//                                          "totalIncome": 30.0,
//                                          "color": "#AAAAAA",
//                                          "dateOpened": Date() ])
//            account.save(toRealm: realm!)
//            presenter.register(withEmail: "user2", withPassword: "user2", withName: "user2")
            
            // #####
            // Offline first, login to sync: user choose to drop local data and use only existing data
            // #####
//            let realm = RealmHolder.sharedInstance.userRealm
//            let cashAccountType = AccountType.with(key: 218, inRealm: realm!)
//            let account = Account(value: ["id": "accnt4-login",
//                                          "name": "Another Cash",
//                                          "type": cashAccountType!,
//                                          "initialAmount": 10.0,
//                                          "currentAmount": 20.0,
//                                          "totalExpenses": 100.0,
//                                          "totalIncome": 30.0,
//                                          "color": "#AAAAAA",
//                                          "dateOpened": Date()])
//            account.save(toRealm: realm!)
//            presenter.login(withEmail: "user1", withPassword: "user1", loginSyncOption: .useRemote)
            
            // #####
            // Offline first, register to sync: user chooses to append local data to remote data
            // #####
//                let realm = RealmHolder.sharedInstance.userRealm
//                let cashAccountType = AccountType.with(key: 218, inRealm: realm!)
//                let account = Account(value: ["id": "accnt4-to-sync",
//                                              "name": "Another Cash",
//                                              "type": cashAccountType!,
//                                              "initialAmount": 10.0,
//                                              "currentAmount": 20.0,
//                                              "totalExpenses": 100.0,
//                                              "totalIncome": 30.0,
//                                              "color": "#AAAAAA",
//                                              "dateOpened": Date()])
//                account.save(toRealm: realm!)
//                presenter.login(withEmail: "user1", withPassword: "user1", loginSyncOption: .append)
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - RealmAuthPresenterOutput methods
    func showSuccessfulLogin(ofUser user: RLMSyncUser) {
        print(RealmHolder.sharedInstance.userRealm?.objects(Account.self) ?? "No accounts")
    }
    
    func showSuccessfulRegistration(ofUser user: RLMSyncUser) {

    }
    
    func showSuccesfulLogout() {
        
    }

    func showFailedAuth(withAlert alert: UIAlertController?) {
        
    }
}
