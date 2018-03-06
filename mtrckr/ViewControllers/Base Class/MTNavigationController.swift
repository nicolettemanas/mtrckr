//
//  MTNavigationController.swift
//  mtrckr
//
//  Created by User on 6/8/17.
//
//

import UIKit

class MTNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
