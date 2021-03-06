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

/// Class responsible for reading Bundle's json files and populate the initial realm
class InitialRealmGenerator {

    /// Creates a bundled `.realm` from json files found in the bundle
    ///
    /// - Parameter onComplete: Block to execute after the creation of realm given the path
    /// of the created initial realm
    static func generateInitRealm(onComplete: (_ path: URL?) -> Void) {

        if SyncUser.current != nil {
            onComplete((try? Realm())?.configuration.syncConfiguration?.realmURL)
            return
        }

        makeInitDir()

        var initialConfiguration: Realm.Configuration = Realm.Configuration()
        initialConfiguration.fileURL = initialConfiguration.fileURL!
                                        .deletingLastPathComponent()
                                        .appendingPathComponent("initRealm/\(initRealmFileName).realm")

        let initialRealm: Realm = try! Realm(configuration: initialConfiguration)

        let lookups: [String] = ["Currency", "Category", "AccountType"]
        for lookup: String in lookups {
            print("[INIT REALM] Reading contents of file \(lookup).json")
            do {
                guard let path: String = Bundle.main.path(forResource: lookup, ofType: "json") else {
                    fatalError("Missing \(lookup).json for initial values")
                }

                let array = try readJSONFile(at: URL(fileURLWithPath: path))
                try initialRealm.write({
                    for item: Any in array {
                        initialRealm.dynamicCreate(lookup, value: item, update: true)
                    }
                })

            } catch let error as NSError {
                fatalError("Error in reading file \(lookup).json: \(error)")
            }
        }

        print("[INIT REALM] Saved realm in \(String(describing: initialRealm.configuration.fileURL))")
        onComplete(initialRealm.configuration.fileURL)
    }

    private static func makeInitDir() {
        let fileManager: FileManager = FileManager.default
        let docsDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let realmDir: URL = URL(fileURLWithPath: docsDir, isDirectory: true).appendingPathComponent("initRealm")
        if fileManager.fileExists(atPath: realmDir.path) {
            return
        } else {
            try? fileManager.createDirectory(at: realmDir, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private static func readJSONFile(at url: URL) throws -> [Any] {
        let jsonData: Data = try Data(contentsOf: url, options: NSData.ReadingOptions.dataReadingMapped)
        let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        guard let result = jsonResult as? [Any] else { fatalError("Cannot convert to array") }
        return result
    }
}
