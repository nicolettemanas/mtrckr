//
//  BillHeaderView.swift
//  mtrckr
//
//  Created by User on 11/1/17.
//

import UIKit

class BillHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var imgPadding: UIView!
    @IBOutlet var img: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var amount: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        contentView.backgroundColor = .white
        amount.textColor = MTColors.mainBlue
    }
    
    func setValue(bill: Bill, currency: String) {
        img.image = UIImage(named: bill.category!.icon) ?? nil
        amount.text = NumberFormatter.currencyStr(withCurrency: currency, amount: bill.amount)
        name.text = bill.name
        imgPadding.backgroundColor = UIColor(bill.category!.color)
        img.tintColor = .white
    }
}
