//
//  AppDelegate.swift
//  mtrckr
//
//  Created by User on 4/5/17.
//
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // **************
        // TODO: Remove this when auth process is finished
        // logout every run
        InitialRealmGenerator.generateInitRealm { (_) in
            if SyncUser.current != nil {
                RealmLogoutInteractor().logout()
            }
            _ = RealmHolder.sharedInstance.userRealm
        }
        
        // **************
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

}
