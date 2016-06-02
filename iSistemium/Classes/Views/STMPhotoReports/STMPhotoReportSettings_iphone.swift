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
        self.navigationItem.title = NSLocalizedString(self.navigationItem.title!, comment: "")
    }
    
    @IBOutlet weak var onlyPhotosLabel: UILabel!{
        didSet{
            onlyPhotosLabel.text = NSLocalizedString(onlyPhotosLabel.text!, comment: "")
        }
    }
    
    @IBOutlet weak var groupingLabel: UILabel!{
        didSet{
            groupingLabel.text = NSLocalizedString(groupingLabel.text!, comment: "")
        }
    }
    
    @IBOutlet weak var campaignLabel: UILabel!{
        didSet{
            campaignLabel.text = NSLocalizedString(campaignLabel.text!, comment: "")
        }
    }
    
    @IBOutlet weak var outletLabel: UILabel!{
        didSet{
            outletLabel.text = NSLocalizedString(outletLabel.text!, comment: "")
        }
    }
}