//
//  EmptyAccountsDataSource.swift
//  mtrckr
//
//  Created by User on 7/4/17.
//

import UIKit
import DZNEmptyDataSet

class EmptyAccountsDataSource: NSObject, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return Colors.emptyDataSetBg.color
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str =  NSLocalizedString("Welcome to Money Tracker!",
                                     comment: "The title shown when there are no accounts registered.")
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        let attr = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                    NSAttributedStringKey.foregroundColor: Colors.placeholderText.color,
                    NSAttributedStringKey.paragraphStyle: style]
        return NSAttributedString(string: str, attributes: attr)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = NSLocalizedString("You are almost settled! Start tracking \n by tapping the '+' " +
                                    " button and \n adding a new account.",
                                    comment: "The description shown when there are no accounts registered. " +
                                    "Instructs user how to add an account.")
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        let attr = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                    NSAttributedStringKey.foregroundColor: Colors.placeholderText.color,
                    NSAttributedStringKey.paragraphStyle: style]
        return NSAttributedString(string: str, attributes: attr)
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "coins")
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return Colors.placeholderText.color
    }

}
