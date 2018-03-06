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
        UINavigationBar.appearance().backgroundColor = MTColors.mainBg
        UINavigationBar.appearance().tintColor = MTColors.mainText
        UINavigationBar.appearance().isOpaque = true
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: MTColors.mainBlue]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = MTColors.barBg
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

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
