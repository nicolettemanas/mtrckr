//
//  MTTableViewController.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit
import Realm
import RealmSwift

/// Base class of UITableViewController. All general UI setups are
/// prepared here.
class MTTableViewController: UITableViewController {
    
    deinit {
        print("[TABLEVIEW CONTROLLER] Deallocating \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MTColors.lightBg
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back-tab")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back-tab")
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = MTColors.separatorColor
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupNavBar(title navTitle: String, leftSelector: Selector, rightSelector: Selector, target: Any?) {
        title = navTitle
        let left = UIBarButtonItem(image    : UIImage(named: "x-tab"),
                                   style    : .plain,
                                   target   : target,
                                   action   : leftSelector)
        let right = UIBarButtonItem(image   : UIImage(named: "check-tab"),
                                    style   : .plain,
                                    target  : target,
                                    action  : rightSelector)
        
        left.tintColor = MTColors.mainRed
        right.tintColor = MTColors.mainBlue
        navigationItem.leftBarButtonItem = left
        navigationItem.rightBarButtonItem = right
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}

extension UITableView {
    
    /// Applies `.automatic` table row animations to the changes received in `RealmCollectionChange`
    ///
    /// - Parameter changes: The `RealmCollectionChange` received
    func applyChanges<T>(changes: RealmCollectionChange<T>) {
        switch changes {
        case .initial: reloadData()
        case .update(_, let deletions, let insertions, let updates):
            let fromRow = { (row: Int) in return IndexPath(row: row, section: 0) }
            
            beginUpdates()
            insertRows(at: insertions.map(fromRow), with: .automatic)
            reloadRows(at: updates.map(fromRow), with: .automatic)
            deleteRows(at: deletions.map(fromRow), with: .automatic)
            endUpdates()
        case .error(let error): fatalError("\(error)")
        }
    }
    
    
    /// Applies `.automatic` table row and section animations to the changes received in `RealmCollectionChange`.
    /// Works for single notification blocks per table section
    ///
    /// - Parameters:
    ///   - index: The section index to modify
    ///   - changes: The `RealmCollectionChange` received
    ///   - inserting: Whether or not to insert the new section index to the `UITableview`
    func applyChanges<T>(forSection index: Int, changes: RealmCollectionChange<T>, inserting: Bool) {
        switch changes {
        case .initial: reloadData()
        case .update(_, let deletions, let insertions, let updates):
            let fromRow = { (row: Int) in return IndexPath(row: row, section: index) }

            beginUpdates()
            if inserting { insertSections([index], with: .automatic) }
            insertRows(at: insertions.map(fromRow), with: .automatic)
            reloadRows(at: updates.map(fromRow), with: .automatic)
            deleteRows(at: deletions.map(fromRow), with: .automatic)
            endUpdates()
        case .error(let error): fatalError("\(error)")
        }
    }
}
