//
//  CustomCalendarCell.swift
//  mtrckr
//
//  Created by User on 7/25/17.
//

import UIKit
import JTAppleCalendar

class CustomCalendarCell: JTAppleCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!

    let nonMonthTextColor: UIColor = UIColor("#C9CCE2FF")
    let unselectedDateLabelColor: UIColor = .white
    let selectedDateLabelColor: UIColor = .white

    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateLabel.textColor = Colors.mainText.color
    }

    func configureCell(cellState: CellState) {
        self.dateLabel.alpha = 1

        if cellState.date.isToday {
            selectToday()
            return
        }

        self.selectionView.layer.borderWidth = 0
        if isSelected {
            self.selectionView.isHidden = false
            self.dateLabel.textColor = selectedDateLabelColor
        } else {
            self.selectionView.isHidden = true
            self.dateLabel.textColor = unselectedDateLabelColor

            if cellState.dateBelongsTo != .thisMonth {
                self.dateLabel.textColor = nonMonthTextColor
                self.dateLabel.alpha = 0.5
            }
        }
    }

    func selectToday() {
        self.selectionView.isHidden = false
        self.selectionView.layer.borderColor = UIColor.white.cgColor
        self.selectionView.layer.borderWidth = 0.8
        self.dateLabel.textColor = selectedDateLabelColor
    }
}
