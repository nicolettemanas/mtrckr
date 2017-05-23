//
//  EncryptionInteractor.swift
//  mtrckr
//
//  Created by User on 5/23/17.
//
//

import UIKit
import CryptoSwift

let key = "1234567890123456"
let iv = "0987654321098765"


protocol EncryptionInteractorProtocol {
    func encrypt(str: String) -> String
}

class EncryptionInteractor: EncryptionInteractorProtocol {
    
    // TODO: Build configurations for key and iv
    
    func encrypt(str: String) -> String {
        do {
            let aes = try AES(key: key, iv: iv, blockMode: .CBC)
            let ciphertext = try aes.encrypt(Array(str.utf8))
            return ciphertext.toHexString()
        } catch let error as NSError {
            fatalError("Failed to encrypt text \(error)")
        }
    }
}
