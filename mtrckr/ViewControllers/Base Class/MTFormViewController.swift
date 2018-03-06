//
//  MTFormViewController.swift
//  mtrckr
//
//  Created by User on 9/12/17.
//

import UIKit
import Eureka

/// The base class for FormViewController which handles defailt row styles
class MTFormViewController: FormViewController {

    deinit {
        print("[VIEW CONTROLLER] Deallocating \(self)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultRows()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Pre-composed setup for the Navigation Bar. Adds left and right bar button items (x and check icons)
    ///
    /// - Parameters:
    ///   - navTitle: The title to display in the Navigation Bar
    ///   - leftSelector: The selector to invoke when left bar button item is tapped
    ///   - rightSelector: The selector to invoke when right bar button item is tapped
    ///   - target: The target of the selectors
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

        left.tintColor = Colors.mainRed.color
        right.tintColor = Colors.mainBlue.color
        navigationItem.leftBarButtonItem = left
        navigationItem.rightBarButtonItem = right
    }

    private func setupDefaultRows() {
        TextRow.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.titleLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.titleLabel?.textColor = Colors.mainText.color
            cell.textField.font = UIFont.mySystemFont(ofSize: 13)
            cell.textField.textColor = Colors.subText.color
            cell.selectionStyle = .none
            row.validationOptions = .validatesOnDemand
            row.add(rule: RuleRequired())
            row.cellUpdate({ (ce, ro) in
                if !ro.isValid {
                    ce.titleLabel?.textColor = Colors.mainRed.color
                    ce.backgroundColor = Colors.subRed.color
                } else {
                    ce.backgroundColor = .white
                }
            })
        }

        TextRow.defaultOnCellHighlightChanged = { cell, _ in
            cell.titleLabel?.textColor = Colors.mainBlue.color
        }

        DecimalRow.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.titleLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.titleLabel?.textColor = Colors.mainText.color
            cell.textField.font = UIFont.mySystemFont(ofSize: 13)
            cell.textField.textColor = Colors.subText.color
            cell.selectionStyle = .none
            row.validationOptions = .validatesOnDemand
            row.add(rule: RuleRequired())
            row.cellUpdate({ (ce, ro) in
                if !ro.isValid {
                    ce.titleLabel?.textColor = Colors.mainRed.color
                    ce.backgroundColor = Colors.subRed.color
                } else {
                    ce.backgroundColor = .white
                }
            })
        }

        DecimalRow.defaultOnCellHighlightChanged = {cell, _ in
            cell.textLabel?.textColor = Colors.mainBlue.color
        }

        DateRow.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.textLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.textLabel?.textColor = Colors.mainText.color
            cell.selectionStyle = .none
        }

        DateRow.defaultOnCellHighlightChanged = {cell, _ in
            cell.textLabel?.textColor = Colors.mainBlue.color
        }

        PushRow<String>.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.textLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.textLabel?.textColor = Colors.mainText.color
            cell.textLabel?.font = UIFont.mySystemFont(ofSize: 13)
            cell.textLabel?.textColor = Colors.subText.color
            cell.selectionStyle = .none
            row.validationOptions = .validatesOnDemand
            row.add(rule: RuleRequired())
            row.cellUpdate({ (ce, ro) in
                if !ro.isValid {
                    ce.textLabel?.textColor = Colors.mainRed.color
                    ce.backgroundColor = Colors.subRed.color
                } else {
                    ce.backgroundColor = .white
                }
            })
        }
    }
}
