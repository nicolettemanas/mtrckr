//
//  NewAccountsViewController+SwipeCell.swift
//  mtrckr
//
//  Created by User on 7/4/17.
//

import Foundation
import SwipeCellKit
import UIKit

extension AccountsTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        if orientation == .right {
            let edit = SwipeAction(style: .default, title: nil) { _, indexPath in
                self.editAccount(atIndex: indexPath)
            }

            edit.accessibilityLabel = "Edit"
            edit.image = #imageLiteral(resourceName: "edit")
            edit.backgroundColor = MTColors.mainBlue
            edit.textColor = .white

            let delete = SwipeAction(style: .destructive, title: nil, handler: { (_, _) in
                self.confirmDelete(atIndex: indexPath)
            })

            delete.accessibilityLabel = "Delete"
            delete.image = #imageLiteral(resourceName: "trash")
            delete.backgroundColor = MTColors.mainRed
            delete.textColor = .white

            return [delete, edit]
        }

        return []
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .none
        options.transitionStyle = .border
        return options
    }
}
