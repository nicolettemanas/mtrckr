//
//  AppDelegate.swift
//  mtrckr
//
//  Created by User on 4/5/17.
//
//

import UIKit
import RealmSwift
import Realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        super.init()
        UIFont.overrideInitialize()
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UIApplication.shared.statusBarStyle = .default
        UINavigationBar.appearance().backgroundColor = Colors.mainBg.color
        UINavigationBar.appearance().tintColor = Colors.mainText.color
        UINavigationBar.appearance().isOpaque = true
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: Colors.mainBlue.color]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = Colors.barBg.color
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

        let filePath = RealmAuthConfig().offlineRealmFileName
        if !FileManager.default.fileExists(atPath: filePath) {
            InitialRealmGenerator.generateInitRealm { (_) in
                let holder = RealmContainer(withConfig: RealmAuthConfig())
                _ = holder.userRealm
            }
        } else { }
        
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
