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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - RealmAuthPresenterOutput methods
    func showSuccessfulLogin(ofUser user: MTSyncUser) {
//        print(RealmHolder.sharedInstance.userRealm?.objects(Account.self) ?? "No accounts")
    }
    
    func showSuccessfulRegistration(ofUser user: MTSyncUser) {

    }
    
    func showSuccesfulLogout() {
        
    }

    func showFailedAuth(withAlert alert: UIAlertController?) {
        
    }
}
