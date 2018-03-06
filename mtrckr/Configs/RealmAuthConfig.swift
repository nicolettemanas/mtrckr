//
//  RealmAuthConfig.swift
//  mtrckr
//
//  Created by User on 5/19/17.
//
//

import Foundation
import Realm
import RealmSwift

let buildConfig = Bundle.main.object(forInfoDictionaryKey: "BUILD_CONFIG_NAME") as? String
let domain = Bundle.main.object(forInfoDictionaryKey: "DOMAIN") as? String

/// Protocol to conform to when making a Realm Authentication Configuration
/// Used by instances of `RealmHolder`
protocol AuthConfig {

    /// The domain where the Realm Object Server is hosted
    var domainHost: String { get }

    /// The URL of the host in format "http(s)://"
    var serverURL: URL { get }

    /// The URL of the host in format "realm://server-url"
    var realmDomainURL: URL { get }

    /// The path of the synced realm when uploaded to the Realm Object Server
    var userRealmPath: URL { get }

    /// Timeout in seconds
    var timeout: TimeInterval { get }

    /// The path of the offline realm in the bundle
    var offlineRealm: URL { get }

    /// The path of the initial realm in the bundle
    var initialRealm: URL { get }

    /// Array of model names to be included in Realm migrations
    var objects: [String] { get }

    /// The file name of the initial realm
    var initRealmFileName: String { get }

    // The file name of the offline realm
    var offlineRealmFileName: String { get }
}

struct RealmAuthConfig: AuthConfig {
    var initRealmFileName: String = "mtrckr-\(buildConfig ?? "dev")-init-db"
    var offlineRealmFileName: String = "mtrckr-\(buildConfig ?? "dev")"

    var domainHost: String = "\(domain ?? "localhost"):9443"
    var serverURL: URL
    var realmDomainURL: URL
    var userRealmPath: URL
    var timeout = TimeInterval(30)
    var initialRealm: URL
    var offlineRealm: URL
    var objects: [String] = ["Account", "AccountType", "Bill", "BillEntry",
                             "Category", "Currency", "Transaction", "User"]

    init() {
        let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        self.initialRealm = URL(fileURLWithPath: docsDir).appendingPathComponent("initRealm/\(initRealmFileName).realm")
        self.offlineRealm = URL(fileURLWithPath: docsDir)
            .appendingPathComponent("initRealm/\(offlineRealmFileName).realm")
        self.serverURL = URL(string: "https://\(domainHost)/")!
        self.realmDomainURL = URL(string: "realms://\(domainHost)")!
        guard let config = buildConfig else { fatalError("Cannot identify build configuration") }
        self.userRealmPath = URL(string: "\(self.realmDomainURL)/~/mtrckr-\(config)")!
    }
}
