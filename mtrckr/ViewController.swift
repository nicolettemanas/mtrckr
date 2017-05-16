//
//  ViewController.swift
//  mtrckr
//
//  Created by User on 4/5/17.
//
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let output = RealmAuthPresenter()
        let interactor = RealmAuthInteractor(output: output)
        interactor.login(withEmail: "nicolettemanas@gmail.com",
                         withPassword: "crixalis",
                         toServer: URL(string: "http://localhost:9080/")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
