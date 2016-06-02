//
//  STMPhotoReportSettings_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMPhotoReportSettings_iphone:UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 320, height: 160)
        self.tableView.estimatedRowHeight = 45
    }
    
}