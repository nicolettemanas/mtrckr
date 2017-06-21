//
//  MockEncrypter.swift
//  mtrckr
//
//  Created by User on 6/15/17.
//
//

import UIKit
@testable import mtrckr

class MockEncrypter: EncryptionInteractor {
    var didEncrypt = false
    
    override func encrypt(str: String) -> String {
        didEncrypt = true
        return "encrypted \(str)"
    }
}
