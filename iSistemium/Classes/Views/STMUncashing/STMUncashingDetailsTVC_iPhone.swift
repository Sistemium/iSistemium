//
//  STMUncashingDetailsTVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 09/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMUncashingDetailsTVC_iPhone: STMUncashingDetailsTVC {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.toolbarHidden = false
    }
}
