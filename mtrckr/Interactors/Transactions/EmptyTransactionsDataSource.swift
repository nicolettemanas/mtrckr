//
//  EmptyTransactionsDataSource.swift
//  mtrckr
//
//  Created by User on 7/18/17.
//

import UIKit
import DZNEmptyDataSet

class EmptyTransactionsDataSource: NSObject, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return Colors.emptyDataSetBg.color
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = NSLocalizedString(
            "No transactions recorded.\nTap '+' button to add one.",
            comment: """
            The description shown when there are no transactions saved.
            Instructs user how to add a Transaction.
            """)

        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        let attr = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
            NSAttributedStringKey.foregroundColor: Colors.placeholderText.color,
            NSAttributedStringKey.paragraphStyle: style]

        return NSAttributedString(string: str, attributes: attr)
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "tags")
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return Colors.placeholderText.color
    }
}
