//
//  MockRegistrationViewController.swift
//  mtrckr
//
//  Created by User on 6/15/17.
//
//

import UIKit
@testable import mtrckr

class MockRegistrationViewController: RegistrationViewController {

    var shouldProceedRegistration: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
