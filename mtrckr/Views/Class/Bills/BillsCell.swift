//
//  BillsCell.swift
//  mtrckr
//
//  Created by User on 8/18/17.
//

import UIKit

protocol BillsCellDelegate: class {
    func didPressPayBill(entry: BillEntry)
}

class BillsCell: UITableViewCell {
    
    weak var delegate: BillsCellDelegate?
    weak var billEntry: BillEntry?

    @IBOutlet weak var billName: UILabel!
    @IBOutlet weak var billAmount: UILabel!
    @IBOutlet weak var billDueDate: UILabel!
    @IBOutlet weak var billIcon: UIImageView!
    @IBOutlet weak var billIconView: UIView!
    @IBOutlet weak var payButton: UIButton!
    
    @IBAction func payButtonDidPress(sender: UIButton) {
        guard let entry = self.billEntry else { return }
        delegate?.didPressPayBill(entry: entry)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        billIcon.layer.cornerRadius = 5
        billIcon.layer.masksToBounds = true
        payButton.layer.cornerRadius = 5
        payButton.layer.masksToBounds = true
        billAmount.textColor = MTColors.subText
        billDueDate.textColor = MTColors.subText
        billName.textColor = MTColors.mainText
        billIconView.layer.cornerRadius = 10
    }

    func setValue(of entry: BillEntry, currency: String) {
        billEntry = entry
        billIcon.image = UIImage(named: entry.bill!.category!.icon) ?? nil
        billAmount.text = NumberFormatter.currencyKString(withCurrency: currency, amount: entry.amount)
        billName.text = entry.bill?.name ?? "No name"
        billIconView.backgroundColor = UIColor(entry.bill!.category!.color)
        billIcon.tintColor = .white
        billDueDate.text = "| Due: " + entry.dueDate.format(with: DateFormatter.Style.medium)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
