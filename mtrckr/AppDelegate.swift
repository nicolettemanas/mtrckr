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
        // Override point for customization after application launch.
        
        UIApplication.shared.statusBarStyle = .default
        UINavigationBar.appearance().backgroundColor = MTColors.mainBg
        UINavigationBar.appearance().tintColor = MTColors.mainText
        UINavigationBar.appearance().isOpaque = true
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: MTColors.mainText]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = MTColors.barBg
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

        // **************
        // TODO: Remove this when auth process is finished
        // logout every run
        InitialRealmGenerator.generateInitRealm { (_) in
//            let holder = RealmHolder(config: RealmAuthConfig())
//            _ = holder.realmHolder.userRealm
////            _ = realmHolder.userRealm
        }
        
        // **************
        
//                InitialRealmGenerator.generateInitRealm { (_) in
//                    let regInteractor = RealmRegInteractor(config: RealmAuthConfig())
//                    let loginInteractor = RealmLoginInteractor(config: RealmAuthConfig())
//                    let logoutInteractor = RealmLogoutInteractor(config: RealmAuthConfig())
//                    let presenter = RealmAuthPresenter(regInteractor: regInteractor,
//                                                       loginInteractor: loginInteractor,
//                                                       logoutInteractor: logoutInteractor,
//                                                       encrypter: EncryptionInteractor(),
//                                                       output: nil)
//                    regInteractor.output = presenter
//                    loginInteractor.output = presenter
//                    logoutInteractor.output = presenter
//        
//                    if SyncUser.current != nil {
//                        logoutInteractor.logout()
//                    }
        
        // #####
        // Offline first, register to sync
        // #####
//                    let realm = RealmHolder(config: RealmAuthConfig()).realmHolder.userRealm
//                    let cashAccountType = AccountType.with(key: 218, inRealm: realm!)
//                    let account = Account(value: ["id": "accnt2",
//                                                  "name": "My Cash",
//                                                  "type": cashAccountType!,
//                                                  "initialAmount": 10.0,
//                                                  "currentAmount": 20.0,
//                                                  "totalExpenses": 100.0,
//                                                  "totalIncome": 30.0,
//                                                  "color": "#AAAAAA",
//                                                  "dateOpened": Date() ])
//                    account.save(toRealm: realm!)
//                    presenter.register(withEmail: "user27@gmail.com", withPassword: "user27", withName: "user27")
        
        // #####
        // Offline first, login to sync: user choose to drop local data and use only existing data
        // #####
//                    let realm = RealmHolder(config: RealmAuthConfig()).realmHolder.userRealm
//                    let cashAccountType = AccountType.with(key: 218, inRealm: realm!)
//                    let account = Account(value: ["id": "accnt-only---1",
//                                                  "name": "Another Cash",
//                                                  "type": cashAccountType!,
//                                                  "initialAmount": 10.0,
//                                                  "currentAmount": 20.0,
//                                                  "totalExpenses": 100.0,
//                                                  "totalIncome": 30.0,
//                                                  "color": "#AAAAAA",
//                                                  "dateOpened": Date()])
//                    account.save(toRealm: realm!)
//                    presenter.login(withEmail: "user23@gmail.com", withPassword: "user23", loginSyncOption: .useRemote)
        
        // #####
        // Offline first, register to sync: user chooses to append local data to remote data
        // #####
//                        let realm = RealmHolder(config: RealmAuthConfig()).realmHolder.userRealm
//                        let cashAccountType = AccountType.with(key: 218, inRealm: realm!)
//                        let account = Account(value: ["id": "accnt6-to-sync",
//                                                      "name": "Another Cash",
//                                                      "type": cashAccountType!,
//                                                      "initialAmount": 10.0,
//                                                      "currentAmount": 20.0,
//                                                      "totalExpenses": 100.0,
//                                                      "totalIncome": 30.0,
//                                                      "color": "#AAAAAA",
//                                                      "dateOpened": Date()])
//                        account.save(toRealm: realm!)
//                        presenter.login(withEmail: "user23@gmail.com", withPassword: "user23", loginSyncOption: .append)
//                }
        
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
