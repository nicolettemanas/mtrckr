//
//  BillsDataSource+TableView.swift
//  mtrckr
//
//  Created by User on 10/23/17.
//

import Foundation
import UIKit

extension BillsDataSource: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillsCell") as? BillsCell else {
            fatalError("Cannot convert UITableViewCell to BillsCell")
        }
        guard let entry = diffCalculator?.value(atIndexPath: indexPath) else {
            fatalError("Invalid row index")
        }
        
        cell.setValue(of: entry, currency: currency!)
        cell.delegate = delegate
        cell.billsCellDelegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let entry = entry(at: indexPath) else { return }
        delegate?.didSelect(entry: entry)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(
            frame: CGRect(origin  : CGPoint.zero,
                          size    : CGSize(
                            width  : tableView.frame.size.width,
                            height : 20)))
        
        let label = UILabel(
            frame   : CGRect(
                origin  : CGPoint(x: 10, y: 0),
                size    : view.frame.size))
        
        view.addSubview(label)
        
        guard let headerStr = diffCalculator?.value(forSection: section) else {
            fatalError("Invalid section index")
        }
        
        if headerStr == BillSections.overdue.rawValue {
            view.backgroundColor = MTColors.subRed
        } else if headerStr == BillSections.sevenDays.rawValue {
            view.backgroundColor = MTColors.subBlue
        } else {
            view.backgroundColor = MTColors.lightBg
        }
        
        let attributes = [NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 12)]
        label.attributedText = NSAttributedString(string: headerStr, attributes: attributes)
        if !displayedSectionStack.contains(headerStr) { displayedSectionStack.insert(headerStr, at: section) }
        return view
    }
}
