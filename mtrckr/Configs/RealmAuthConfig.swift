//
//  RealmAuthConfig.swift
//  mtrckr
//
//  Created by User on 5/19/17.
//
//

import Foundation

let buildConfig = "dev"

protocol AuthConfigProtocol {
    var domainHost: String { get }
    var serverURL: URL { get }
    var realmDomainURL: URL { get }
    var userRealmPath: URL { get }
    var timeout: TimeInterval { get }
}

struct RealmAuthConfig: AuthConfigProtocol {
    var domainHost: String = "192.168.2.27:9080"
    var serverURL: URL
    var realmDomainURL: URL
    var userRealmPath: URL
    var timeout = TimeInterval(30)
    
    init() {
        self.serverURL = URL(string: "http://\(domainHost)/")!
        self.realmDomainURL = URL(string: "realm://\(domainHost)")!
        self.userRealmPath = URL(string: "\(self.realmDomainURL)/~/mtrckr-\(buildConfig)")!
    }
}
