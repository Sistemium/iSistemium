//
//  STMCashingControlsVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 22/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMCashingControlsVC_iPhone: STMCashingControlsVC {
    
    // MARK: Override superclass
    
    override func customInit() {
        self.title = NSLocalizedString("CASHING", comment:"")
        self.labelsInit()
        self.updateControlLabels()
    }
    
    // MARK: view lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
}
