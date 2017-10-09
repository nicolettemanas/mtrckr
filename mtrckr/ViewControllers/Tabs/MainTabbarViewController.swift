//
//  MainTabbarViewController.swift
//  mtrckr
//
//  Created by User on 7/26/17.
//

import UIKit

class MainTabbarViewController: UITabBarController {
    let addBtn = UIButton(type: .custom)
    
    var newTransactionPresenter: NewTransactionPresenterProtocol?
    var transactionsPresenter: TransactionsPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBtn.frame = CGRect(x: 100, y: 0, width: 44, height: 44)
        addBtn.backgroundColor = .white
        addBtn.addTarget(self, action: #selector(addBtnPressed), for: .touchUpInside)
        addBtn.imageView?.tintColor = MTColors.mainBlue
        addBtn.setImage(#imageLiteral(resourceName: "add-tab"), for: .normal)
        self.view.addSubview(addBtn)
        
        newTransactionPresenter = NewTransactionPresenter()
        transactionsPresenter = TransactionsPresenter(with: TransactionsInteractor(with: RealmAuthConfig()))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBtn.frame = CGRect(x: tabBar.center.x - 32,
                              y: view.bounds.height - 74,
                              width: 64,
                              height: 64)
        addBtn.layer.cornerRadius = 32
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = MTColors.lightBg.cgColor
        tabBar.shadowImage = UIImage.colorForNavBar(color: MTColors.lightBg)
        tabBar.backgroundImage = UIImage.colorForNavBar(color: .white)
        tabBar.tintColor = .white
    }
    
    @objc func addBtnPressed() {
        newTransactionPresenter?.presentNewTransactionVC(with: nil,
                                                         presentingVC: self,
                                                         delegate: self)
    }
}

extension MainTabbarViewController: NewTransactionViewControllerDelegate {
    func update(transaction: Transaction, withValues name: String, amount: Double,
                type: TransactionType, date: Date, category: Category?, from sourceAcc: Account,
                to destAccount: Account) {
        fatalError("Tabbar shouldn't receive udpdate transaction")
    }
    
    func shouldSaveTransaction(with name: String, amount: Double, type: TransactionType,
                               date: Date, category: Category?, from sourceAcc: Account, to destAccount: Account) {
        transactionsPresenter?.createTransaction(with: name, amount: amount, type: type, date: date,
                                                 category: category, from: sourceAcc, to: destAccount)
    }
}

extension UIImage {
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
