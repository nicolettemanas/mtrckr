//
//  UserObserver.swift
//  mtrckr
//
//  Created by User on 7/3/17.
//

import UIKit
import RealmSwift
import Realm

/// The methods exposed by the `UserObserver`
protocol ObserverProtocol {
    
    /// Sets the block to execute when a user changed status
    /// fired by login/logout
    ///
    /// - Parameter block: The block to execute
    func setDidChangeUserBlock(with block: @escaping () -> Void)
}

/// Tells the class to hold an `observer` to listen to
/// current user changes (login, logout). (Ex: refresh realm url)
protocol UserObserver {
    
    /// The actual observer of the notifications
    var observer: ObserverProtocol? { get }
}

/// A class conforming to `ObserverProtocol`
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
