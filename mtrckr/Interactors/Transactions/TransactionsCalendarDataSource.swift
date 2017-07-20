//
//  TransactionsCalendarDataSource.swift
//  mtrckr
//
//  Created by User on 7/18/17.
//

import UIKit
import FSCalendar

protocol TransactionsCalendarDataSourceProtocol: FSCalendarDelegate, FSCalendarDataSource {
    
}

class TransactionsCalendarDataSource: NSObject, TransactionsCalendarDataSourceProtocol {
    weak var calendar: FSCalendar?
    weak var transactionsDataSource: TransactionsListDataSourceProtocol?
    
    init(calendar cal: FSCalendar, transactionsDataSource dataSource: TransactionsListDataSourceProtocol) {
        calendar = cal
        transactionsDataSource = dataSource
    }
        
    // MARK: - FSCalendarDelegate methods
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return transactionsDataSource?.sumOfDate(date: date, account: []).0
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        configure(cell: cell, for: date, at: monthPosition)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        transactionsDataSource?.reloadByDate(with: date)
        configureCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        configureCells()
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as? TransactionCalendarCell
            else { fatalError("TransactionCalendarCell not registered") }
        return cell
    }
    
    // MARK: - Private calendar methods
    private func configureCells() {
        calendar?.visibleCells().forEach { (cell) in
            guard   let date = calendar?.date(for: cell),
                    let position = calendar?.monthPosition(for: cell) else { return }
            self.configure(cell: cell, for: date, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        guard let customCell = (cell as? TransactionCalendarCell) else { return }
        if customCell.isSelected {
            customCell.customSelectionView.isHidden = false
        } else {
            customCell.customSelectionView.isHidden = true
        }
        
        customCell.subtitleLabel.isHidden = false
        customCell.incomeSubtitleLabel?.isHidden = false
        
        if cell.dateIsToday {
            customCell.customSelectionView.isHidden = true
            customCell.selectionLayer.isHidden = false
            customCell.titleLabel.textColor = MTColors.mainText
        } else {
            customCell.selectionLayer.isHidden = true
        }
        
        let sum = transactionsDataSource?.sumOfDate(date: date, account: [])
        customCell.subtitleLabel?.text = sum?.0
        customCell.incomeSubtitleLabel?.text = sum?.1
    }
}
