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

class MTTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MTColors.lightBg
        self.tableView.separatorStyle = .none
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back-tab")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back-tab")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}
