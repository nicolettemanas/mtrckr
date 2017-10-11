//
//  BillsTableViewController++SwipeTableViewCell.swift
//  mtrckr
//
//  Created by User on 9/28/17.
//

import Foundation
import SwipeCellKit

extension BillsTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .right {
            let edit: SwipeAction = SwipeAction(style: .default, title: nil) { [unowned self] _, _ in
                self.editBillEntry(atIndex: indexPath)
            }
            
            edit.accessibilityLabel = "Edit"
            edit.image = #imageLiteral(resourceName: "edit")
            edit.backgroundColor = MTColors.mainBlue
            edit.textColor = .white
            
            let delete: SwipeAction = SwipeAction(style: .destructive, title: nil, handler: { [unowned self] _, _ in
                self.deleteBillEntry(atIndex: indexPath)
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
