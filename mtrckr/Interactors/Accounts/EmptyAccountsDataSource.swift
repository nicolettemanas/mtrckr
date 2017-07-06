//
//  EmptyAccountsDataSource.swift
//  mtrckr
//
//  Created by User on 7/4/17.
//

import UIKit
import DZNEmptyDataSet

class EmptyAccountsDataSource: NSObject, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str =  NSLocalizedString("Welcome to Money Tracker!",
                                     comment: "The title shown when there are no accounts registered.")
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        let attr = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
                    NSForegroundColorAttributeName: MTColors.placeholderText,
                    NSParagraphStyleAttributeName: style]
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
        let attr = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                    NSForegroundColorAttributeName: MTColors.placeholderText,
                    NSParagraphStyleAttributeName: style]
        return NSAttributedString(string: str, attributes: attr)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let img = #imageLiteral(resourceName: "coins")
        return img
    }
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return MTColors.placeholderText
    }
    
}
