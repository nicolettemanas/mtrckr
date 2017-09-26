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
