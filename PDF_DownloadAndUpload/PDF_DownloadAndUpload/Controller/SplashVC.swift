//
//  SplashVC.swift
//  PDF_DownloadAndUpload
//
//  Created by Shashikant's Mac on 5/15/19.
//  Copyright © 2019 redbytes. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {
    // MARK:- Outlets
    let segueID = "pushTODashboardVC"
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.performSegue(withIdentifier: self.segueID, sender: self)
        }
    }

}//class

