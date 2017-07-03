//
//  UserObserver.swift
//  mtrckr
//
//  Created by User on 7/3/17.
//

import UIKit
import RealmSwift
import Realm

protocol ObserverProtocol {
    func setDidChangeUserBlock(with block: @escaping () -> Void)
}

protocol UserObserver {
    var observer: ObserverProtocol? { get }
}

class NotificationObserver: ObserverProtocol {
    
    func setDidChangeUserBlock(with block: @escaping () -> Void) {
        didChangeUserBlock = block
    }
    
    private var didChangeUserBlock: (() -> Void) = {
        fatalError("Must set block to execute when user logs in/logs out/registers")
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeUser),
                                               name: NSNotification.Name(rawValue: "didChangeUser"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
     @objc private func didChangeUser() {
        didChangeUserBlock()
    }
}
