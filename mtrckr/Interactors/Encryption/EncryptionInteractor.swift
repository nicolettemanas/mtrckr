//
//  EncryptionInteractor.swift
//  mtrckr
//
//  Created by User on 5/23/17.
//
//

import UIKit
//import CryptoSwift

/// :nodoc:
protocol EncryptionInteractorProtocol {
    func encrypt(str: String) -> String
}

/// Class responsible for encryption
class EncryptionInteractor: EncryptionInteractorProtocol {
    
    /// Encrypts given string using Advanced Encryption Standard (AES)
    ///
    /// - Parameter str: The string to be encrypted
    /// - Returns: The encrypted string
    func encrypt(str: String) -> String {
//        TODO: Encrypt this
        return str
//        do {
//            guard let iv = Bundle.main.object(forInfoDictionaryKey: "CRYPT_IV") as? String,
//                let key = Bundle.main.object(forInfoDictionaryKey: "CRYPT_KEY") as? String else {
//                    fatalError("No IV and KEY found in bundle")
//            }
//
//            let aes: AES = try AES(key: key, iv: iv, blockMode: .CBC)
//            let ciphertext = try aes.encrypt(Array(str.utf8))
//            return ciphertext.toHexString()
//        } catch let error as NSError {
//            fatalError("Failed to encrypt text \(error)")
//        }
    }
}
