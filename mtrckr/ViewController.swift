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
        interactor.login(withEmail: "user1@gmail.com",
                         withPassword: "user1")

//        interactor.register(withEmail: "user10@gmail.com", withPassword: "user10", withName: "User10")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
