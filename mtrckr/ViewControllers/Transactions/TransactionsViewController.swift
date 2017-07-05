//
//  TransactionsViewController.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit

protocol TransactionsViewControllerProtocol {
    var account: Account? { get set }
}

class TransactionsViewController: MTTableViewController, TransactionsViewControllerProtocol {
    var account: Account?
    
    override func viewDidLoad() {
        
    }
}
