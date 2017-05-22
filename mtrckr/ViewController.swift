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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let output = RealmAuthPresenter()
        let interactor = RealmAuthInteractor(output: output, config: RealmAuthConfig())

        if SyncUser.current != nil {
            interactor.logout()
        }
        
        print(RealmHolder.sharedInstance.userRealm?.objects(Currency.self) ?? "No currencies")
        print(RealmHolder.sharedInstance.userRealm?.objects(AccountType.self) ?? "No currencies")
        print(RealmHolder.sharedInstance.userRealm?.objects(Category.self) ?? "No currencies")
        
        interactor.login(withEmail: "user9@gmail.com",
                         withPassword: "user9")

//        interactor.register(withEmail: "user10@gmail.com", withPassword: "user10", withName: "User10")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
