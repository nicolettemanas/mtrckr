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
            let edit = buildEdit(indexPath: indexPath)
            let delete = buildDelete(indexPath: indexPath)

            return [delete, edit]
        } else {
            return [buildSkip(indexPath: indexPath)]
        }
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {

        var options = SwipeTableOptions()
        options.expansionStyle = .none
        options.transitionStyle = .border

        if orientation == .left {
            options.expansionStyle = SwipeExpansionStyle.destructive(automaticallyDelete: false)
        }

        return options
    }

    private func buildEdit(indexPath: IndexPath) -> SwipeAction {
        let edit: SwipeAction = SwipeAction(style: .default, title: nil) {
            [unowned self] _, index in
            self.editBillEntry(atIndex: index)
        }

        edit.accessibilityLabel = "Edit"
        edit.image = #imageLiteral(resourceName: "edit").resizableImage(withCapInsets:
            UIEdgeInsets(top    : 10,
                         left   : 10,
                         bottom : 10,
                         right  : 10))
        edit.backgroundColor = Colors.mainBlue.color
        edit.textColor = .white

        return edit
    }

    private func buildDelete(indexPath: IndexPath) -> SwipeAction {
        let delete: SwipeAction = SwipeAction(style: .destructive, title: nil) {
            [unowned self] _, index in
            self.deleteBillEntry(atIndex: index)
        }

        delete.accessibilityLabel = "Delete"
        delete.image = #imageLiteral(resourceName: "trash").resizableImage(withCapInsets:
            UIEdgeInsets(top    : 10,
                         left   : 10,
                         bottom : 10,
                         right  : 10))
        delete.backgroundColor = Colors.mainRed.color
        delete.textColor = .white

        return delete
    }

    private func buildSkip(indexPath: IndexPath) -> SwipeAction {
        let skip: SwipeAction = SwipeAction(style: .default, title: nil) {
            [unowned self] _, index in
            self.skipBillEntry(atIndex: index)
        }

        skip.accessibilityLabel = "Skip"
        skip.image = #imageLiteral(resourceName: "skip")
        skip.backgroundColor = Colors.mainOrange.color
        skip.textColor = .white

        return skip
    }
}
