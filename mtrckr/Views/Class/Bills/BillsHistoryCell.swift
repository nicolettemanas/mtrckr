//
//  BillsHistoryCell.swift
//  mtrckr
//
//  Created by User on 10/26/17.
//

import UIKit
import SwipeCellKit

class BillsHistoryCell: SwipeTableViewCell {
    
    @IBOutlet weak var due: UILabel!
    @IBOutlet weak var datePaid: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    static let skipped = NSLocalizedString("bills.skipped",
                                           tableName    : nil,
                                           bundle       : Bundle.main,
                                           value        : "Skipped",
                                           comment      : "Displayed when a bill is skipped")
    static let dueFormat = NSLocalizedString("bills.due.format",
                                             tableName: nil,
                                             bundle: Bundle.main,
                                             value: "Due: %@",
                                             comment: "String format with label 'Due:' followed by the value")
    static let paidFormat = NSLocalizedString("bills.paid.format",
                                             tableName: nil,
                                             bundle: Bundle.main,
                                             value: "Paid: %@",
                                             comment: "String format with label 'Paid:' followed by the value")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        detail.textColor = MTColors.subText
        datePaid.textColor = MTColors.subText
        due.textColor = MTColors.mainText

        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setValue(entry: BillEntry, currency: String) {
        assert(entry.status != BillEntryStatus.unpaid.rawValue)
        due.text = String(format: BillsHistoryCell.dueFormat,
                          entry.dueDate.format(with: DateFormatter.Style.medium))
        
        switch entry.status {
        case BillEntryStatus.paid.rawValue:
            assert(entry.id == entry.transaction?.billEntry?.id)
            amount.textColor = MTColors.mainGreen
            detail.text = entry.transaction?.fromAccount?.name
            datePaid.text = String(format: BillsHistoryCell.paidFormat,
                                   entry.transaction!.transactionDate.format(with: DateFormatter.Style.medium))
        case BillEntryStatus.skipped.rawValue:
            amount.textColor = MTColors.mainOrange
            detail.text = BillsHistoryCell.skipped
        default: fatalError("Invalid bill status: \(entry.status)")
        }
        
        amount.text = NumberFormatter
            .currencyKString(withCurrency   : currency,
                             amount         : entry.amount)
    }
    
}
