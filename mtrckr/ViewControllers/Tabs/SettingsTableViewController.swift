//
//  SettingsTableViewController.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit
import RealmSwift

protocol AuthViewControllerDelegate: class {
    func didDismiss()
}

class SettingsTableViewController: MTTableViewController, AuthViewControllerDelegate, RealmAuthPresenterOutput, UserObserver {
    
    // MARK: - Properties
    var authPresenter: RealmAuthPresenter?
    var settingsPresenter: SettingsPresenterProtocol?
    var settingsDetails: [[String]] = []
    let settingsItems = [["Sync account", "Currency >", "Custom categories >"], ["Log out"]]
    let settingsIcon = [["sync", "currency", "tag"], ["out"]]
    let settingsCellIdentifier = "SettingsCell"
    
    var observer: ObserverProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
        setupUserData()
        observer = NotificationObserver()
        observer?.setDidChangeUserBlock {
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Methods
    func setup() {
        settingsPresenter = SettingsPresenter(with: RealmAuthConfig())
    }
    
    func setupUserData() {
        self.settingsPresenter?.fetchSettingsData({ (details) in
            self.settingsDetails = details
            self.tableView.reloadData()
        })
    }
    
    func setupUI() {
        tableView.separatorStyle = .none
    }
    
    func didDismiss() {
//        setupUserData()
//        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate and UITableViewDatasource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SyncUser.current == nil ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 3
            case 1: return 1
            default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if settingsDetails.count < 1 { return UITableViewCell() }
        
        guard let cell: MTSettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: settingsCellIdentifier) as? MTSettingsTableViewCell
            else {
                fatalError("Cannot dequeue cell with identifier: \(settingsCellIdentifier)")
            }
        
        cell.title.text = settingsItems[indexPath.section][indexPath.row].replacingOccurrences(of: " >", with: "")
        cell.detail.text = settingsDetails[indexPath.section][indexPath.row]
        cell.icon.image = UIImage(named: settingsIcon[indexPath.section][indexPath.row])
        
        if (settingsItems[indexPath.section][indexPath.row]).hasSuffix(">") {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item: String = settingsItems[indexPath.section][indexPath.row]
        switch item {
            case settingsItems[0][0]:
                if SyncUser.current != nil {
                    return
                }
                goToRegistration()
            case settingsItems[0][1]: break
            case settingsItems[0][2]: break
            case settingsItems[1][0]:
                displayLogoutSheet()
                break
            default: break
        }
    }
    
    // MARK: - RealmAuthPresenterOutput methods
    func showSuccesfulLogout() {
//        setupUserData()
//        tableView.reloadData()
    }
    
    func showSuccessfulRegistration(ofUser user: MTSyncUser) {
//        setupUserData()
//        tableView.reloadData()
    }
    
    func showSuccessfulLogin(ofUser user: MTSyncUser) {
//        setupUserData()
//        tableView.reloadData()
    }
    
    // MARK: - UI/UX flow methods
    private func goToRegistration() {
        guard let regViewController = self.storyboard?
            .instantiateViewController(withIdentifier: "RegistrationViewController")
            as? RegistrationViewController
        else {
            fatalError("Cannot find view controller with identifier RegistrationViewController")
        }
        
        // TODO: Use Swinject for these
        let authConfig = RealmAuthConfig()
        let authEncryption = EncryptionInteractor()
        let regInteractor = RealmRegInteractor(with: authConfig)
        authPresenter = RealmAuthPresenter(regInteractor: regInteractor,
                                           loginInteractor: nil,
                                           logoutInteractor: nil,
                                           encrypter: authEncryption,
                                           output: regViewController)
        regInteractor.output = authPresenter
        regViewController.delegate = self
        regViewController.presenter = authPresenter
        
        regViewController.modalTransitionStyle = .coverVertical
        regViewController.modalPresentationStyle = .fullScreen
        present(regViewController, animated: true, completion: nil)
    }
    
    private func displayLogoutSheet() {
        let logoutOptions = UIAlertController(title: nil,
                                             message: "Are you sure you want to log out? " +
                                            "Transactions saved when logged out will not be synced to your account.",
                                             preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            logoutOptions.dismiss(animated: true, completion: nil)
        }
        
        let logoutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            self.performLogout()
        }
        
        logoutOptions.addAction(cancelAction)
        logoutOptions.addAction(logoutAction)
        
        present(logoutOptions, animated: true, completion: nil)
    }
    
    private func performLogout() {
        // TODO: Use Swinject for these
        let logoutInteractor = RealmLogoutInteractor(with: RealmAuthConfig())
        authPresenter = RealmAuthPresenter(regInteractor: nil,
                                           loginInteractor: nil,
                                           logoutInteractor: logoutInteractor,
                                           encrypter: nil,
                                           output: self)
        logoutInteractor.output = authPresenter
        authPresenter?.logout()
    }

}
