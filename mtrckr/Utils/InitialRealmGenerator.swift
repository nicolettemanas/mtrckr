//
//  InitialRealmGenerator.swift
//  mtrckr
//
//  Created by User on 5/31/17.
//
//

import UIKit
import RealmSwift
import Realm

private var initRealmFileName = "mtrckr-dev-init-db"

class InitialRealmGenerator {
    
    static func generateInitRealm(onComplete: (_ path: URL?) -> Void) {
        
        if SyncUser.current != nil {
            print("Has logged in user, skipping generation of init realm...")
            onComplete((try? Realm())?.configuration.syncConfiguration?.realmURL)
            return
        }
        
        makeInitDir()
        
        print("Generating inital Realm...")
        var initialConfiguration = Realm.Configuration()
        initialConfiguration.fileURL = initialConfiguration.fileURL!
                                        .deletingLastPathComponent()
                                        .appendingPathComponent("initRealm/\(initRealmFileName).realm")
        
        let initialRealm = try! Realm(configuration: initialConfiguration)
        
        let lookups = ["Currency", "Category", "AccountType"]
        for lookup in lookups {
            print("Reading contents of file \(lookup).json")
            do {
                guard let path = Bundle.main.path(forResource: lookup, ofType: "json") else {
                    fatalError("Missing \(lookup).json for initial values")
                }
                
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.dataReadingMapped)
                let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                if let array = jsonResult as? [Any] {
                    try initialRealm.write({
                        for item in array {
                            initialRealm.dynamicCreate(lookup, value: item, update: true)
                        }
                    })
                }
                
            } catch let error as NSError {
                fatalError("Error in reading file \(lookup).json: \(error)")
            }
        }
        
        print("Saved realm in \(String(describing: initialRealm.configuration.fileURL))")
        onComplete(initialRealm.configuration.fileURL)
    }
    
    static func makeInitDir() {
        let fileManager = FileManager.default
        let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let realmDir = URL(fileURLWithPath: docsDir, isDirectory: true).appendingPathComponent("initRealm")
        if fileManager.fileExists(atPath: realmDir.path) {
            return
        } else {
            try? fileManager.createDirectory(at: realmDir, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
