//
//  MTSettingsViewController.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit

class MTSettingsTableViewController: MTTableViewController {

    let settingsCellIdentifier = "SettingsCell"
    let settingsItems = [["Profile", "Currency", "Custom categories"], ["Log out"]]
    let settingsDetails = [["", "$", "12"], [""]]
    
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
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MTSettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: settingsCellIdentifier) as? MTSettingsTableViewCell
            else {
                fatalError("Cannot dequeue cell with identifier: \(settingsCellIdentifier)")
            }
        
        cell.title.text = settingsItems[indexPath.section][indexPath.row]
        cell.detail.text = settingsDetails[indexPath.section][indexPath.row]
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: String = settingsItems[indexPath.section][indexPath.row]
        switch item {
            case "Profile":
                guard let regViewController = self.storyboard?
                    .instantiateViewController(withIdentifier: "RegistrationViewController")
                    as? RegistrationViewController else { break }
                
                self.navigationController?.present(regViewController, animated: true, completion: nil)
            case "Currency": break
            case "Custom categories": break
            case "Log out": break
            default: break
        }
    }

}
