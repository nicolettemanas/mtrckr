//
//  MTFormViewController.swift
//  mtrckr
//
//  Created by User on 9/12/17.
//

import UIKit
import Eureka

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
        
        left.tintColor = MTColors.mainRed
        right.tintColor = MTColors.mainBlue
        navigationItem.leftBarButtonItem = left
        navigationItem.rightBarButtonItem = right
    }
    
    private func setupDefaultRows() {
        TextRow.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.titleLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.titleLabel?.textColor = MTColors.mainText
            cell.textField.font = UIFont.mySystemFont(ofSize: 13)
            cell.textField.textColor = MTColors.subText
            row.validationOptions = .validatesOnDemand
            row.add(rule: RuleRequired())
            row.cellUpdate({ (ce, ro) in
                if !ro.isValid {
                    ce.titleLabel?.textColor = MTColors.mainRed
                    ce.backgroundColor = MTColors.subRed
                } else {
                    ce.backgroundColor = .white
                }
            })
        }

        TextRow.defaultOnCellHighlightChanged = { cell, _ in
            cell.titleLabel?.textColor = MTColors.mainBlue
        }

        DecimalRow.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.titleLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.titleLabel?.textColor = MTColors.mainText
            cell.textField.font = UIFont.mySystemFont(ofSize: 13)
            cell.textField.textColor = MTColors.subText
            row.validationOptions = .validatesOnDemand
            row.add(rule: RuleRequired())
            row.cellUpdate({ (ce, ro) in
                if !ro.isValid {
                    ce.titleLabel?.textColor = MTColors.mainRed
                    ce.backgroundColor = MTColors.subRed
                } else {
                    ce.backgroundColor = .white
                }
            })
        }

        DateRow.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.textLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.textLabel?.textColor = MTColors.mainText
        }

        DateRow.defaultOnCellHighlightChanged = {cell, _ in
            cell.textLabel?.textColor = MTColors.mainBlue
        }
        
        PushRow<String>.defaultCellSetup = { cell, row in
            cell.height = { 55 }
            cell.textLabel?.font = UIFont.myBoldSystemFont(ofSize: 14)
            cell.textLabel?.textColor = MTColors.mainText
            cell.textLabel?.font = UIFont.mySystemFont(ofSize: 13)
            cell.textLabel?.textColor = MTColors.subText
            row.validationOptions = .validatesOnDemand
            row.add(rule: RuleRequired())
            row.cellUpdate({ (ce, ro) in
                if !ro.isValid {
                    ce.textLabel?.textColor = MTColors.mainRed
                    ce.backgroundColor = MTColors.subRed
                } else {
                    ce.backgroundColor = .white
                }
            })
        }
    }
}
