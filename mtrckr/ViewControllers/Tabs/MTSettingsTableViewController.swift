//
//  MTSettingsViewController.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit
import Presentr

class MTSettingsTableViewController: MTTableViewController {

    let settingsCellIdentifier = "SettingsCell"
    let settingsItems = [["Sync account", "Currency >", "Custom categories >"], ["Log out"]]
    let settingsDetails = [["None", "$", "12"], [""]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK - UITableViewDelegate and UITableViewDatasource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 3
            case 1: return 1
            default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MTSettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: settingsCellIdentifier) as? MTSettingsTableViewCell
            else {
                fatalError("Cannot dequeue cell with identifier: \(settingsCellIdentifier)")
            }
        
        cell.title.text = settingsItems[indexPath.section][indexPath.row].replacingOccurrences(of: " >", with: "")
        cell.detail.text = settingsDetails[indexPath.section][indexPath.row]
        
        cell.selectionStyle = .gray
        
        if (settingsItems[indexPath.section][indexPath.row]).hasSuffix(">") {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: String = settingsItems[indexPath.section][indexPath.row]
        switch item {
            case settingsItems[0][0]:
                guard let regViewController = self.storyboard?
                    .instantiateViewController(withIdentifier: "RegistrationViewController")
                    as? RegistrationViewController else { break }
                
                let authConfig: AuthConfigProtocol = RealmAuthConfig()
                let authInteractor: RealmAuthInteractorProtocol = RealmAuthInteractor(config: authConfig)
                let authEncryption: EncryptionInteractorProtocol = EncryptionInteractor()
                let authPresenter: RealmAuthPresenter = RealmAuthPresenter(interactor: authInteractor, encrypter: authEncryption, output: regViewController)
                regViewController.presenter = authPresenter
                
                navigationController?.present(regViewController, animated: true, completion: nil)
            case settingsItems[0][1]: break
            case settingsItems[0][2]: break
            case settingsItems[1][0]: break
            default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
