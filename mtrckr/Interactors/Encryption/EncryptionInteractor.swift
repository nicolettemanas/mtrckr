//
//  EncryptionInteractor.swift
//  mtrckr
//
//  Created by User on 5/23/17.
//
//

import UIKit
import CryptoSwift

// TODO: Build configurations for key and iv
let key = "1234567890123456"
let iv = "0987654321098765"

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
//        TODO: CryptoSwift & Swinject not in 'master' branch due to Swift4 compatibilities
        return str
        do {
            let aes = try AES(key: key, iv: iv, blockMode: .CBC)
            let ciphertext = try aes.encrypt(Array(str.utf8))
            return ciphertext.toHexString()
        } catch let error as NSError {
            fatalError("Failed to encrypt text \(error)")
        }
    }
}
