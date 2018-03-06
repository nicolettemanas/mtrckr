//
//  BillHistoryViewController+SwipeTableViewCell.swift
//  mtrckr
//
//  Created by User on 10/30/17.
//

import Foundation
import SwipeCellKit

extension BillHistoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        if orientation == .right {
            return [buildUnpay(indexPath: indexPath)]
        }
        return []
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {

        var options = SwipeTableOptions()
        options.transitionStyle = .border
        options.expansionStyle = SwipeExpansionStyle.destructive(automaticallyDelete: false)

        return options
    }

    private func buildUnpay(indexPath: IndexPath) -> SwipeAction {
        let unpay: SwipeAction = SwipeAction(style: .destructive, title: nil) {
            [unowned self] _, index in
            self.unpay(indexPath: index)
        }

        unpay.accessibilityLabel = "Unpay"
        unpay.image = #imageLiteral(resourceName: "unpay")
        unpay.backgroundColor = MTColors.mainOrange
        unpay.textColor = .white

        return unpay
    }
}
