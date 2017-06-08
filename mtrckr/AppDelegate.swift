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

    override init() {
        super.init()
        UIFont.overrideInitialize()
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().backgroundColor = UIColor(hexString: MTColors.barBg)
        UINavigationBar.appearance().tintColor = UIColor(hexString: MTColors.barBg)
        UINavigationBar.appearance().isOpaque = true
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hexString: MTColors.mainText)!]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = UIColor(hexString: MTColors.barBg)

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
