//
//  RealmAuthConfig.swift
//  mtrckr
//
//  Created by User on 5/19/17.
//
//

import Foundation

protocol AuthConfigProtocol {
    var serverURL: URL { get }
//    var globalPath: URL { get }
    var userRealmPath: URL { get }
    var timeout: TimeInterval { get }
}

struct RealmAuthConfig: AuthConfigProtocol {
    var serverURL: URL = URL(string: "http://localhost:9080/")!
    var userRealmPath = URL(string: "realm://localhost:9080/~/mtrckr-dev")!
//    var globalPath: URL = URL(string: "realm://localhost:9080/shared-dev")!
    var timeout = TimeInterval(30)
}
