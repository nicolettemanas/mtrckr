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

let buildConfig = "dev"

protocol AuthConfigProtocol {
    var domainHost: String { get }
    var serverURL: URL { get }
    var realmDomainURL: URL { get }
    var userRealmPath: URL { get }
    var timeout: TimeInterval { get }
    var offlineRealm: URL { get }
    var objects: [String] { get }
}

struct RealmAuthConfig: AuthConfigProtocol {
    var domainHost: String = "localhost:9080"
    var serverURL: URL
    var realmDomainURL: URL
    var userRealmPath: URL
    var timeout = TimeInterval(30)
    var offlineRealm: URL = Bundle.main.url(forResource: "mtrckr-\(buildConfig)", withExtension: "realm")!
    var objects: [String] = ["Account", "AccountType", "Bill", "BillEntry",
                             "Category", "Currency", "Transaction", "User"]
    
    init() {
        self.serverURL = URL(string: "http://\(domainHost)/")!
        self.realmDomainURL = URL(string: "realm://\(domainHost)")!
        self.userRealmPath = URL(string: "\(self.realmDomainURL)/~/mtrckr-\(buildConfig)")!
    }
    
}
