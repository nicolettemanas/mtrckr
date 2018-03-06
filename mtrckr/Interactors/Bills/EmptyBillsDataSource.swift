//
//  EmptyBillsDataSource.swift
//  mtrckr
//
//  Created by User on 9/28/17.
//

import UIKit
import DZNEmptyDataSet

class EmptyBillsDataSource: NSObject, DZNEmptyDataSetSource {

    struct LocalizableStrings {
        static let emptyBillsTitle = NSLocalizedString("You have no scheduled bills.",
                comment: "The title shown when there are no bills registered.")
        static let emptyBillsBody = NSLocalizedString("Tap the '+' button to add one.",
                comment: """
                        The description shown when there are no bills registered.
                        Instructs user how to add a bill.
                        """)
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return MTColors.emptyDataSetBg
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = LocalizableStrings.emptyBillsTitle
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        let attr = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                    NSAttributedStringKey.foregroundColor: MTColors.placeholderText,
                    NSAttributedStringKey.paragraphStyle: style]
        return NSAttributedString(string: str, attributes: attr)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = LocalizableStrings.emptyBillsBody
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        let attr = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                    NSAttributedStringKey.foregroundColor: MTColors.placeholderText,
                    NSAttributedStringKey.paragraphStyle: style]
        return NSAttributedString(string: str, attributes: attr)
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "bill")
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return MTColors.placeholderText
    }
}
